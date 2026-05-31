from flask import Flask, jsonify

app = Flask(__name__)

details_menu = {
    "Pizza Margherita": {
        "cena": 30.0,
        "sklad": ["ciasto", "sos pomidorowy", "ser mozzarella", "oregano"],
        "alergeny": ["gluten", "laktoza"]
    },
    "Pizza Capricciosa": {
        "cena": 38.0,
        "sklad": ["ciasto", "sos pomidorowy", "ser", "pieczarki", "szynka"],
        "alergeny": ["gluten", "laktoza"]
    },
    "Pizza Pepperoni": {
        "cena": 39.0,
        "sklad": ["ciasto", "sos pomidorowy", "ser", "salami pepperoni"],
        "alergeny": ["gluten", "laktoza", "soja", "gorczyca"]
    },
    "Pizza Hawajska": {
        "cena": 37.0,
        "sklad": ["ciasto", "sos pomidorowy", "ser", "szynka", "ananas"],
        "alergeny": ["gluten", "laktoza"]
    },
    "Pizza Vegetariana": {
        "cena": 35.0,
        "sklad": ["ciasto", "sos pomidorowy", "ser", "papryka", "cebula", "oliwki"],
        "alergeny": ["gluten", "laktoza"]
    },
    "Pizza Quattro Formaggi": {
        "cena": 40.0,
        "sklad": ["ciasto", "sos pomidorowy", "ser mozzarella", "gorgonzola", "parmezan", "ricotta"],
        "alergeny": ["gluten", "laktoza"]
    },
    "Pizza Diavola": {
        "cena": 39.0,
        "sklad": ["ciasto", "sos pomidorowy", "ser", "pikantne salami", "papryczki chili"],
        "alergeny": ["gluten", "laktoza", "soja", "gorczyca"]
    }
}

# Endpoint API
@app.route('/', methods=['GET'])
def pobierz_menu():
    return jsonify(details_menu)

if __name__ == '__main__':
    app.run(debug=True, port=5000)