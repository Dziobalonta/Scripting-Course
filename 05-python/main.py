import json
import ollama
import requests

def grab_API_data():
    try:
        res = requests.get('http://localhost:5000/')
        return res.json()

    except Exception as e :
        print("Flask server is not up. Try Runinng app.py first.")

def load_config(path):
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

config = load_config('restaurant.json')
details = grab_API_data()

system_prompt = f"""
    Jesteś wirtualnym asystentem restauracji. Twoje główne zadania to:
    1. Rozpoznawać intencję powitania i miło witać klientów.
    2. Na prośbę klienta prezentować pozycje z menu oraz godziny otwarcia.
    3. Przyjmować zamówienia na podstawie dostępnego menu.

    Oto Twoja baza wiedzy o restauracji:
    - Godziny otwarcia: {json.dumps(config['godziny_otwarcia'], ensure_ascii=False)}
    - Nasze menu: {json.dumps(config['pozycje'], ensure_ascii=False)}
    - Szczegółowe dane o posiłkach - składniki i alergeny: {json.dumps(details, ensure_ascii=False)}

    Zasady:
    - Bądź uprzejmy, zwięzły i pomocny.
    - Oferuj tylko te dania, które znajdują się w Twojej bazie wiedzy.
    - Nie wymyślaj własnych potraw ani cen.
    - Nie wymyślaj własnych drinków ani napojów.
    - Nie używaj emotek ani nie dodawaj żadnych ozdobników do swojej odpowiedzi.
    - Gdy klient zada pytanie, przeszukaj bazę wiedzy o restauracji. Gdy nie ma tam odpowiedzi na pytanie, grzecznie przyznaj, że nie masz tej informacji i zaproponuj, że możesz pomóc w czymś innym.
    - gdy klient poprosi o coś czego nie ma w menu, grzecznie poinformuj, że nie posiadamy takiej pozycji i zaproponuj coś innego z menu.
    - Po wyborze klienta przedstaw podsumowanie zamówionych pozycji wypisując je jedna po drugiej. Spytaj klienta czy lista się zgadza i czy życzyłby sobie coś jeszcze. Jeśli nie, poinformuj, że przekazujesz zamówienie do realizacji.
    - Jeśli klient prosi o modyfikację dania (np. usunięcie składnika), koniecznie uwzględnij to w końcowym podsumowaniu zamówienia.
    """

chat_history = [
    {'role': 'system', 'content': system_prompt}
]

print("Bot działa! Napisz \"koniec\" aby wyjść z programu.\n" + "-"*50)

# 3. Pętla konwersacyjna
while True:
    user_text = input("Ty: ")
    
    if user_text.lower() in ['koniec', 'wyjdz', 'exit']:
        print("Bot: Do zobaczenia!")
        break
        
    # Add users answer to memory
    chat_history.append({'role': 'user', 'content': user_text})
    
    # Send all the content to the model
    response = ollama.chat(model='gemma4:e2b', messages=chat_history)
    
    # Take only response (without thinking)
    bot_text = response['message']['content']
    print(f"Bot: {bot_text}")
    
    # Save bot response to remeber
    chat_history.append({'role': 'assistant', 'content': bot_text})