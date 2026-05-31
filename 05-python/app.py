from flask import Flask, jsonify, request

app = Flask(__name__)

orders = []

details_menu = {
    "Pizza Margherita": {
        "cena": 30.0,
        "sklad": ["ciasto", "sos pomidorowy", "ser mozzarella", "oregano"],
        "alergeny": ["gluten", "laktoza"],
        "czas_przygotowania_min": 15
    },
    "Pizza Capricciosa": {
        "cena": 38.0,
        "sklad": ["ciasto", "sos pomidorowy", "ser", "pieczarki", "szynka"],
        "alergeny": ["gluten", "laktoza"],
        "czas_przygotowania_min": 15
    },
    "Pizza Pepperoni": {
        "cena": 39.0,
        "sklad": ["ciasto", "sos pomidorowy", "ser", "salami pepperoni"],
        "alergeny": ["gluten", "laktoza", "soja", "gorczyca"],
        "czas_przygotowania_min": 15
    },
    "Pizza Hawajska": {
        "cena": 37.0,
        "sklad": ["ciasto", "sos pomidorowy", "ser", "szynka", "ananas"],
        "alergeny": ["gluten", "laktoza"],
        "czas_przygotowania_min": 15
    },
    "Pizza Vegetariana": {
        "cena": 35.0,
        "sklad": ["ciasto", "sos pomidorowy", "ser", "papryka", "cebula", "oliwki"],
        "alergeny": ["gluten", "laktoza"],
        "czas_przygotowania_min": 15
    },
    "Pizza Quattro Formaggi": {
        "cena": 40.0,
        "sklad": ["ciasto", "sos pomidorowy", "ser mozzarella", "gorgonzola", "parmezan", "ricotta"],
        "alergeny": ["gluten", "laktoza"],
        "czas_przygotowania_min": 15
    },
    "Pizza Diavola": {
        "cena": 39.0,
        "sklad": ["ciasto", "sos pomidorowy", "ser", "pikantne salami", "papryczki chili"],
        "alergeny": ["gluten", "laktoza", "soja", "gorczyca"],"czas_przygotowania_min": 15
    }
}

# Endpoint API
@app.route('/', methods=['GET'])
def get_menu():
    return jsonify(details_menu)

@app.route('/', methods=['POST'])
def save_order():
    bot_data = request.json
    orders.append(bot_data)

    print(f"\n New order: {bot_data}\n")

    return jsonify({"status": "sukces", "msg": "Zamówienie przyjęte do realizacji"})

if __name__ == '__main__':
    app.run(debug=True, port=5000)