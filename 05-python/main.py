import json
import ollama
import requests

debug = True

def grab_API_data():
    try:
        req = requests.get('http://api:5000/')
        return req.json()

    except Exception as e :
        print("Flask server is not up. Try Runinng app.py first.")
        return {}

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
    - Szczegółowe dane o posiłkach - składniki, alergeny i czas przygotowania w minutach: {json.dumps(details, ensure_ascii=False)}

    Zasady ogólne:
    - Bądź uprzejmy, zwięzły i pomocny.
    - Oferuj tylko te dania, które znajdują się w bazie wiedzy. Nie wymyślaj własnych potraw, napojów ani cen.
    - Nie używaj emotikonów ani żadnych ozdobników tekstowych.
    - Jeśli nie znasz odpowiedzi, przyznaj to grzecznie. Jeśli czegoś nie ma w menu, zaproponuj alternatywę.

    Proces obsługi zamówienia (KROK PO KROKU):
    KROK 1 - ZBIERANIE INFORMACJI: Przyjmuj zamówienie. Jeśli klient prosi o modyfikację dań, zapamiętaj to.
    KROK 2 - PODSUMOWANIE: Gdy klient skończy wybierać, wypisz zamówione pozycje jedna po drugiej (np. "2x Pizza Hawajska"). Podaj estymowany czas przygotowania i zapytaj: "Czy lista się zgadza?".
    KROK 3 - ADRES (BARDZO WAŻNE): Dopiero po tym, jak klient zatwierdzi listę jedzenia, ZAPYTAJ GO O ADRES DOSTAWY.
    KROK 4 - WERYFIKACJA ADRESU: Musisz zebrać od klienta 3 informacje: ULICĘ, NUMER DOMU oraz MIASTO. Jeśli brakuje którejkolwiek z tych danych, dopytuj klienta.
    KROK 5 - FINALIZACJA: Gdy masz już potwierdzone jedzenie ORAZ pełny, trzyczęściowy adres, poinformuj klienta, że zamówienie trafia do realizacji.

    ABSOLUTNY ZAKAZ:
    Na samym końcu wiadomości z KROKU 5 musisz dodać tag: [KONIEC].
    JEDNAKŻE, SUROWO ZABRANIAM CI używania tagu [KONIEC], dopóki nie zbierzesz od klienta pełnego adresu (ulica, numer domu, miasto).
    """

chat_history = [
    {'role': 'system', 'content': system_prompt}
]

print("Bot działa! Napisz \"koniec\" aby wyjść z programu.\n" + "-"*50)

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

    if "[KONIEC]" in bot_text:
        rm_tag_bot_text = bot_text.replace("[KONIEC]", "").strip()

        # pritn last msg to client
        print(f"Bot: {rm_tag_bot_text}")

        if debug:
            print("[DEBUG] Sending data to Flask...")

        extract_data = """
        Przeanalizuj powyższą konwersację. Wyciągnij z niej ostateczne zamówienie klienta oraz jego pełny adres dostawy.
        Zwróć wynik WYŁĄCZNIE jako obiekt JSON o następującej strukturze:
        {
            "pozycje": ["nazwa pizzy 1", "nazwa pizzy 2"],
            "adres": {
                "ulica": "nazwa ulicy",
                "numer": "numer budynku",
                "miasto": "nazwa miasta"
            }
        }
        Nie pisz żadnego dodatkowego tekstu, tylko czysty kod JSON.
        """

        secret_chat_history = chat_history.copy()
        secret_chat_history.append({'role': 'system', 'content': extract_data})

        secret_response = ollama.chat(model='gemma4:e2b', messages=secret_chat_history, format='json')
        order_json = json.loads(secret_response['message']['content'])

        res = requests.post('http://api:5000/',json=order_json)

        if debug:
            print("[DEBUG] Operation sucessful!")

        break
    
    else:
        print(f"Bot: {bot_text}")
        
        # Save bot response to remeber
        chat_history.append({'role': 'assistant', 'content': bot_text})