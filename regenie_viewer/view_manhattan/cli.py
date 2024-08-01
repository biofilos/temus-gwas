import pandas as pd
from pathlib import Path
from dash_bio import ManhattanPlot
from dash.html import Div, Br, Label, Table, Tbody, Th,Td, Tr,P,Thead, Span
from dash import Dash, Input, Output
from dash.dcc import Graph, RadioItems, Slider, Dropdown, Store
from sys import argv
import json

def make_table(pop, phe, files):
    """
    Concatenate all the regenie files for a given population and phenotype.
    In production, this function should be replaced by a call to a database.
    :param pop: str, population name
    :param phe: str, phenotype name
    :return: pd.DataFrame, concatenated table
    """
    selection = f"regenie2_{pop}_*_{phe}.regenie"
    tab = pd.concat((pd.read_csv(x, sep=" ") for x in files.glob(selection)), axis=0).sort_values(["CHROM","GENPOS"])
    return tab.to_json(orient="split")

def make_html_tab(data, threshold):
    """
    Create a html table from the concatenated regenie files.
    :param pop: str, population name
    :param phe: str, phenotype name
    :return: str, html table
    """
    rows = []
    
    for rec in json.loads(data)["data"]:
        if rec[11] >= threshold:
            rows.append(Tr([Td(rec[0]), Td(rec[1]), Td(rec[2]), Td(rec[11])]))
    if rows:
        tab_data = Table([
            Thead([
                Tr([Th("CHROM"), Th("GENPOS"), Th("ID"), Th("-Log10(P)")])
            ]),
            Tbody(rows)
        ])
    else:
        tab_data = P("No variants above threshold")
    return tab_data

def main():
    files = Path(argv[1])

    app = Dash(__name__)

    pops = list(sorted({x.name.split("_")[1] for x in files.glob("*.regenie")}))


    if not pops:
        raise ValueError("No regenie files found in the directory")

    phenos = list(sorted({x.name.split("_")[3].split(".")[0] for x in files.glob("*.regenie")},
                        key=lambda x: int(x[1:] if x.startswith("Y") else x)))
    app.layout = Div([
        'Population',
        RadioItems(
            pops,
            pops[0],
            id='pop_menu',
            inline=True
        ),
        Br(),
        
        Label(
            "Phenotype",
            htmlFor="pheno"
        ),
        Dropdown(
            phenos,
            phenos[0],
            id="pheno",
            clearable=False
        ),
        Br(),
        Label("Threshold value", htmlFor="threshold"),
        Slider(
            id="threshold",
            min=1,
            max=10,
            marks={
                i: {"label": str(i)} for i in range(10)
            },
            value=6
        ),
        Br(),
        Div(Graph(id="graph")),
        Br(),
        P([Span("Variants above the -Log10(Pvalue) threshold: "),Span(id="vars_thres")]),
        Div(id="var_table"),
        Store(id="v_tab")
    ])

    @app.callback(Output("v_tab", "data"),
                Input("pop_menu", "value"), 
                Input("pheno", "value"))
    def update_table(pop, pheno,):
        return [make_table(pop, pheno, files), pop, pheno]
    
    @app.callback(Output("graph", "figure"),
                  Input("v_tab", "data"),
                Input("threshold", "value"))
    def update_manhattan(tab_data, threshold):
        return ManhattanPlot(dataframe=pd.read_json(tab_data[0], orient="split").sort_values(["CHROM","GENPOS"]),
                        title=f"Manhattan plot for population {tab_data[1]}. Trait {tab_data[2]}",
                        gene=None, chrm="CHROM", bp="GENPOS",snp="ID",
                                    genomewideline_value=threshold,
                        p="LOG10P", logp=False)
    

    @app.callback(Output("var_table", "children"),
                  Input("v_tab", "data"),
                  Input("threshold", "value"))
    def update_htmltable(tab_data, threshold):
        return make_html_tab(tab_data[0], threshold)
    
    @app.callback(Output("vars_thres", "children"),
                    Input("threshold", "value"))
    def update_threshold(threshold):
        return threshold
        
    app.run_server()

if __name__ == '__main__':
    main()