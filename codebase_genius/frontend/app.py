import streamlit as st
import requests

st.set_page_config(page_title="Codebase Genius", page_icon="📘")
st.title(" Codebase Genius")
st.write("Generate clean documentation from any public GitHub repo.")

repo_url = st.text_input("Enter GitHub Repository URL")

if st.button("Generate Documentation"):
    if repo_url:
        with st.spinner("Generating documentation..."):
            response = requests.post("http://localhost:8000/generate_docs", json={"url": repo_url})
            if response.ok:
                st.success(" Documentation generation started.")
                st.info("Check the backend output folder for the generated markdown.")
            else:
                st.error(f"Error: {response.text}")