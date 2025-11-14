from flask import Flask, render_template, request, send_file
import pdfkit
from datetime import datetime
import os

path_wkhtml = os.environ.get("WKHTMLTOPDF_PATH", "/usr/bin/wkhtmltopdf")
logo_path = "static/Logo2.png"
sello_path = "static/sello.png"

config = pdfkit.configuration(wkhtmltopdf=path_wkhtml)

app = Flask(__name__)

config = config = pdfkit.configuration(wkhtmltopdf="/usr/local/bin/wkhtmltopdf")


options = {
    "enable-local-file-access": "",
    "encoding": "UTF-8",
}

@app.template_filter("format_currency")
def format_currency(value):
    return f"${value:,.2f}"

@app.route("/")
def index():
    return render_template("form.html")

@app.route("/generar", methods=["POST"])
def generar():
    titulo = request.form.get("titulo")
    mensaje = request.form.get("mensaje").replace("\n", "<br>")
    if mensaje == "":
        mensaje = "Estimados, de parte de Simelab se adjunta la propuesta de exámenes."
    notas = request.form.get("notas").replace("\n", "<br>")

    nombres = request.form.getlist("item_nombre")
    cantidades = request.form.getlist("item_cantidad")
    precios = request.form.getlist("item_precio")

    items = []
    subtotal = 0

    for name, qty, price in zip(nombres, cantidades, precios):
        qty = int(qty) if qty else 1
        price = float(price)
        total_item = qty * price
        subtotal += total_item
        items.append({
            "name": name,
            "qty": qty,
            "price": price
        })

    total = subtotal  # si luego quieres impuestos, aquí lo cambias

    render_html = render_template(
        "plantilla.html",
        titulo=titulo,
        mensaje=mensaje,
        notas=notas,
        items=items,
        subtotal=subtotal,
        total=total,
        fecha=datetime.now().strftime("%d/%m/%Y"),
        logo_path=logo_path,
        sello_path=sello_path,
        embebido_css=open("static/styles.css", "r", encoding="utf-8").read()
    )

    with open("proforma_render.html", "w", encoding="utf-8") as f:
        f.write(render_html)

    pdfkit.from_file(
    "proforma_render.html",
    "proforma.pdf",
    configuration=config,
    options=options,
    css = "static/styles.css"
    )

    return send_file("proforma.pdf", as_attachment=True)

if __name__ == "__main__":
    port = int(os.environ.get("PORT",5000))
    app.run(host="0.0.0.0", port=port)
