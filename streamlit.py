# Import python packages
import streamlit as st
import pandas as pd
import altair as alt
from snowflake.snowpark.context import get_active_session

# ----------------------------
# 📊 Configuration de la page Streamlit
# ----------------------------
st.set_page_config(page_title="Analyse des offres d'emploi", layout="wide")
st.title("💼 Tableau de bord des offres d'emploi (Snowflake)")


# Get the current credentials
session = get_active_session()

# ----------------------------
# 🔍 Exécution de requêtes
# ----------------------------
def run_query(query):
    try:
        return session.sql(query).to_pandas()
    except Exception as e:
        st.error(f"Erreur de requête : {e}")
        return pd.DataFrame()

# ----------------------------
# 📁 Sélecteur de visualisation
# ----------------------------
option = st.selectbox(
    "Choisissez une visualisation :",
    [
        "Top 10 industries avec le plus de postes",
        "Top 10 industries avec les salaires les plus élevés",
        "Répartition des offres d’emploi par secteur d’activité",
        "Répartition des offres d’emploi par type d’emploi"
    ]
)

# ----------------------------
# 📊 Visualisation 1 : top 10 industries avec le plus de postes
# ----------------------------
if option == "Top 10 industries avec le plus de postes":
    query = """
        SELECT 
            i.industry_name,
            COUNT(*) AS nb_postes
        FROM jobs_postings_clean jp
        JOIN job_industries_clean ji ON jp.job_id = ji.job_id
        JOIN industries_csv i ON ji.industry_id = i.industry_id
        WHERE i.industry_name IS NOT NULL
        GROUP BY i.industry_name
        ORDER BY nb_postes DESC
        LIMIT 10
    """

    st.code(query, language="sql")

    # Exécution et affichage
    df = run_query(query)
    st.dataframe(df)

    # Graphique Altair
    if not df.empty:
        df['nb_postes'] = pd.to_numeric(df['NB_POSTES'], errors='coerce')
        df['industry_name'] = df['INDUSTRY_NAME'].astype(str)

        chart = alt.Chart(df).mark_bar().encode(
            x=alt.X('nb_postes:Q', title='Nombre de postes'),
            y=alt.Y('industry_name:N', sort='-x', title="Secteur d'activité"),
            color=alt.Color('industry_name:N', scale=alt.Scale(scheme='tableau20')),
            tooltip=['industry_name', 'nb_postes']
        ).properties(width=700, height=400)
        st.altair_chart(chart)
    else:
        st.warning("Aucune donnée à afficher.")

# ----------------------------
# 📊 Visualisation 2 : top 10 industries avec les salaires les plus élevés
# ----------------------------
elif option == "Top 10 industries avec les salaires les plus élevés":
    query2 = """
        SELECT industry_name, MAX(max_salary) AS salaire_max
        FROM (
            SELECT 
                i.industry_name,
                TRY_TO_DOUBLE(jp.max_salary) AS max_salary
            FROM jobs_postings_clean jp
            JOIN job_industries_clean ji ON jp.job_id = ji.job_id
            JOIN industries_csv i ON ji.industry_id = i.industry_id
            WHERE i.industry_name IS NOT NULL AND jp.max_salary IS NOT NULL
        )
        GROUP BY industry_name
        ORDER BY salaire_max DESC
        LIMIT 10
    """

    st.code(query2, language="sql")

    # Exécution et affichage
    df2 = run_query(query2)
    st.dataframe(df2)

    # Graphique Altair (type: cercle)
    if not df2.empty:
        df2['salaire_max'] = pd.to_numeric(df2['SALAIRE_MAX'], errors='coerce')
        df2['industry_name'] = df2['INDUSTRY_NAME'].astype(str)

        chart2 = alt.Chart(df2).mark_circle(size=200).encode(
            x=alt.X('salaire_max:Q', title='Salaire maximum (€)'),
            y=alt.Y('industry_name:N', sort='-x', title="Secteur d'activité"),
            color=alt.Color('industry_name:N', scale=alt.Scale(scheme='category20b')),
            tooltip=['industry_name', 'salaire_max']
        ).properties(width=700, height=400)
        st.altair_chart(chart2)
    else:
        st.warning("Aucune donnée salariale à afficher.")

# ----------------------------
# 📊 Visualisation 4 : répartition des offres d’emploi par secteur d’activité
# ----------------------------
elif option == "Répartition des offres d’emploi par secteur d’activité":
    query3 = """
        SELECT 
            i.industry_name,
            COUNT(*) AS nb_offres
        FROM jobs_postings_clean jp
        JOIN job_industries_clean ji ON jp.job_id = ji.job_id
        JOIN industries_csv i ON ji.industry_id = i.industry_id
        WHERE i.industry_name IS NOT NULL
        GROUP BY i.industry_name
        ORDER BY nb_offres DESC
    """

    st.code(query3, language="sql")

    # Exécution et affichage
    df3 = run_query(query3)
    st.dataframe(df3)

    if not df3.empty:
        df3['nb_offres'] = pd.to_numeric(df3['NB_OFFRES'], errors='coerce')
        df3['industry_name'] = df3['INDUSTRY_NAME'].astype(str)

        chart3 = alt.Chart(df3).mark_arc(innerRadius=50).encode(
            theta=alt.Theta(field="nb_offres", type="quantitative"),
            color=alt.Color("industry_name:N", scale=alt.Scale(scheme="set3")),
            tooltip=["industry_name", "nb_offres"]
        ).properties(width=600, height=500)

        st.altair_chart(chart3)
    else:
        st.warning("Aucune donnée disponible pour la répartition.")

# ----------------------------
# 📊 Visualisation 5 : répartition des offres d’emploi par type d’emploi
# ----------------------------
elif option == "Répartition des offres d’emploi par type d’emploi":
    query4 = """
        SELECT 
            formatted_work_type AS type_emploi,
            COUNT(*) AS nb_offres
        FROM jobs_postings_clean
        WHERE formatted_work_type IS NOT NULL
        GROUP BY formatted_work_type
        ORDER BY nb_offres DESC
    """

    st.code(query4, language="sql")

    # Exécution et affichage
    df4 = run_query(query4)
    st.dataframe(df4)

    if not df4.empty:
        df4['nb_offres'] = pd.to_numeric(df4['NB_OFFRES'], errors='coerce')
        df4['type_emploi'] = df4['TYPE_EMPLOI'].astype(str)

        total_offres = int(df4['nb_offres'].sum())

        chart4 = alt.Chart(df4).mark_arc(innerRadius=100).encode(
            theta=alt.Theta(field="nb_offres", type="quantitative"),
            color=alt.Color("type_emploi:N", scale=alt.Scale(scheme="set2")),
            tooltip=["type_emploi", "nb_offres"]
        ).properties(width=600, height=500)

        # Texte au centre
        text = alt.Chart(pd.DataFrame({"x": [0], "y": [0], "text": [f"Total\n{total_offres}"]})).mark_text(
            align="center", baseline="middle", fontSize=20
        ).encode(
            x="x:Q",
            y="y:Q",
            text="text:N"
        )

        st.altair_chart(chart4 + text)
    else:
        st.warning("Aucune donnée disponible pour le type d’emploi.")
