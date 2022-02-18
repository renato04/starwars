import urllib3
import json

http = urllib3.PoolManager()
people_url = 'https://swapi.dev/api/people?search=Skywalker'

phrase = "{character} participated in {movies}."

def handle(event, context):
    response = http.request('GET', people_url)
    response_json = json.loads(response.data)

    characters = {}

    for item in response_json['results']:
        films = []
        for film in item['films']:
            response = http.request('GET', film)
            films_json = json.loads(response.data)
            films.append(films_json['title'])

        characters[item['name']] = films

    characters_phrases = []
    for key in characters:
        film_description = ', '.join([film for film in characters[key]])
        last_char_index = film_description.rfind(",")
        film_description_with_and = film_description[:last_char_index] + " and" + film_description[last_char_index+1:]
        character_phrase = phrase.format(character=key, movies=film_description_with_and)
        characters_phrases.append(character_phrase)

    all_phrases = ' '.join(characters_phrases)
    
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "status": 200,
            "description": all_phrases
        })
    }
        