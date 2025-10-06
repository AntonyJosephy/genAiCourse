# early_warnings.jac
# Jac program for evaluating weather forecast products and issuing early warnings.
# Comments explain where to adapt/integrate with external systems.

# ---------- Node / Edge classes ----------
node class ForecastProduct {
    has product_id: str;       # unique id, e.g. "gfs_20251006_00"
    has source: str;           # e.g. "GFS", "ECMWF", "LocalModel"
    has valid_from: str;       # ISO datetime string
    has valid_to: str;         # ISO datetime string
    has geopoly: str;          # WKT or geojson feature id linking to region node
    has payload: str;          # json blob or pointer to external storage (S3 path)
    has ingested_at: str;
}

node class HazardRule {
    has rule_id: str;
    has hazard_type: str;      # "flood", "drought", "hurricane", "wind"
    has severity: str;         # "advisory", "watch", "warning"
    has condition_expr: str;   # string expression to evaluate (see evaluator)
    has priority: int;
    has active: bool;
    has region_id: str;        # region geofence id
    has meta: str;             # extra JSON, e.g., durations, lead_time
}

node class Warning {
    has warning_id: str;
    has hazard_type: str;
    has severity: str;
    has issued_at: str;
    has valid_from: str;
    has valid_to: str;
    has region_id: str;
    has forecast_ref: str;
    has message: str;
    has status: str;           # "issued", "cancelled", "expired"
}

node class Subscriber {
    has sub_id: str;
    has name: str;
    has channels: str;         # JSON string, e.g. {"email":"x","sms":"+254..."}
    has region_interest: str;  # region id or list
    has min_severity: str;     # minimum severity they want to receive
}

edge class FOR_PRODUCT (from: ForecastProduct, to: HazardRule) {}
edge class TRIGGERS (from: HazardRule, to: Warning) {}
edge class SUBSCRIBES (from: Subscriber, to: Warning) {}

# ---------- Actions ----------
# Action: evaluate_condition
# Evaluate a rule.condition_expr against the forecast payload.
# NOTE: Payload is JSON and expressions
# reference fields in a tiny domain-specific way:
#   rainfall_24h > 100 and max_wind_speed > 15
# The evaluator here is a minimal expression parser; in production you should
# call out to a secure expression engine or evaluate in Python microservice.

action evaluate_condition(forecast: node, rule: node) -> bool {
    # Access forecast.payload and rule.condition_expr
    # The following pseudo-eval extracts a flat dict from payload JSON.
    walk {
        has $payload_str = forecast.payload;
        has $expr = rule.condition_expr;
    }

    # Basic safe replacements:
    # Recognize tokens like "rainfall_24h", "max_wind_speed", "mean_pressure"
    # Rplaced with numeric literals read from payload JSON.
    # Note: Jac doesn't include an advanced JSON parser here; expect your ingestion
    # to include flattened forecast fields in payload_flat map.
    # For clarity,forecast.payload is a JSON string with keys for fields.

    # This is placeholder pseudo-evaluation: in real deployment,
    # call an external evaluator (see integration notes).
    emit "EVAL_PLACEHOLDER: " + $expr;
    ret true;   # replace in prod
}

action make_warning(rule: node, forecast: node) -> node {
    has w = spawn Warning;
    w.warning_id = "warn_" + str(now_millis());
    w.hazard_type = rule.hazard_type;
    w.severity = rule.severity;
    w.issued_at = str(now_iso());
    w.valid_from = forecast.valid_from;
    w.valid_to = forecast.valid_to;
    w.region_id = rule.region_id;
    w.forecast_ref = forecast.product_id;
    w.message = "Auto-generated: " + rule.hazard_type + " " + rule.severity;
    w.status = "issued";

    # Create TRIGGERS edge
    create edge TRIGGERS(rule, w);

    ret w;
}

action notify_subscribers(warning: node) {
    # Find subscribers interested in the region or hazard
    # Iterate over subscribers and create SUBSCRIBES edges or call channels
    walk {
        foreach sub in node_subscriber_list() {
            # pseudo filter: if sub.region_interest matches warning.region_id
            # and sub.min_severity <= warning.severity
            create edge SUBSCRIBES(sub, warning);
            # Placeholder for real notification integration:
            emit "Notify " + sub.name + " via channels: " + sub.channels + " msg: " + warning.message;
        }
    }
}

# ---------- Walkers ----------
# walker: ingest_forecast
# Called by external system after creating ForecastProduct node or to ingest
walker ingest_forecast(forecast_ref: node) {
    can be default;
    body {
        emit "Ingesting forecast: " + forecast_ref.product_id;

        # Attach forecast to rules by region or global rules
        # Get all active HazardRule nodes
        has rule_list = get_nodes(HazardRule);
        foreach r in rule_list {
            if (r.active) {
                # For simplicity, attach all rules; real logic should check geofence overlap
                create edge FOR_PRODUCT(forecast_ref, r);
            }
        }

        # Run evaluation walker
        run evaluate_hazards(forecast_ref);
    }
}

# walker: evaluate_hazards
walker evaluate_hazards(forecast_ref: node) {
    can be default;
    body {
        emit "Evaluating hazard rules for: " + forecast_ref.product_id;

        has attached_rules = out_edges(forecast_ref, FOR_PRODUCT) | map(dest);
        foreach rule in attached_rules {
            has ok = evaluate_condition(forecast_ref, rule);
            if (ok) {
                # create a warning and notify subscribers
                has w = make_warning(rule, forecast_ref);
                run notify_subscribers(w);
            }
        }
    }
}

# ---------- Utility helpers ----------
# A helper to list subscriber nodes (replace with actual get_nodes)
action node_subscriber_list() -> list {
    has subs = get_nodes(Subscriber);
    ret subs;
}

# Start-up utility to load example rules (call once)
walker bootstrap() {
    can be default;
    body {
        # Example rule: flood watch if 24-hr rainfall > 80 mm
        has r1 = spawn HazardRule;
        r1.rule_id = "flood_80mm";
        r1.hazard_type = "flood";
        r1.severity = "watch";
        r1.condition_expr = "rainfall_24h >= 80";
        r1.priority = 10;
        r1.active = true;
        r1.region_id = "COUNTY_ABC";
        r1.meta = "{}";

        # Example rule: strong wind warning
        has r2 = spawn HazardRule;
        r2.rule_id = "wind_60kmh";
        r2.hazard_type = "wind";
        r2.severity = "warning";
        r2.condition_expr = "max_wind_kph >= 60";
        r2.priority = 8;
        r2.active = true;
        r2.region_id = "COUNTY_ABC";
        r2.meta = "{}";

        # Example subscriber
        has s = spawn Subscriber;
        s.sub_id = "sub_1";
        s.name = "County Emergency Manager";
        s.channels = '{"email":"anton.ouma111@gmail.com","sms":"+254706247146"}';
        s.region_interest = "COUNTY_ABC";
        s.min_severity = "advisory";

        emit "Bootstrapped rules and subscriber";
    }
}
