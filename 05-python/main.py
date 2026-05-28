import json
import ollama

def load_config(path):
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

config = load_config('restaurant.json')

system_prompt = f"""
    Jesteś wirtualnym asystentem restauracji. Twoje główne zadania to:
    1. Rozpoznawać intencję powitania i miło witać klientów.
    2. Na prośbę klienta prezentować pozycje z menu oraz godziny otwarcia.
    3. Przyjmować zamówienia na podstawie dostępnego menu.

    Oto Twoja baza wiedzy o restauracji:
    - Godziny otwarcia: {json.dumps(config['godziny_otwarcia'], ensure_ascii=False)}
    - Nasze menu: {json.dumps(config['pozycje'], ensure_ascii=False)}

    Zasady:
    - Bądź uprzejmy, zwięzły i pomocny.
    - Oferuj tylko te dania, które znajdują się w Twojej bazie wiedzy.
    - Nie wymyślaj własnych potraw ani cen.
    - Nie wymyślaj własnych drinków ani napojów.
    - Nie używaj emotek ani nie dodawaj żadnych ozdobników do swojej odpowiedzi.
    - Gdy klient zada pytanie, na które nie znasz odpowiedzi, grzecznie przyznaj, że nie masz tej informacji i zaproponuj, że możesz pomóc w czymś innym.
    - gdy klient poprosi o coś czego nie ma w menu, grzecznie poinformuj, że nie posiadamy takiej pozycji i zaproponuj coś innego z menu.
    """

chat_history = [
    {'role': 'system', 'content': system_prompt}
]

print("Czatbot uruchomiony! Napisz 'koniec' aby wyjść z programu.\n" + "-"*50)

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