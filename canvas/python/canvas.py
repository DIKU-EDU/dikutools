import urllib.parse
import urllib.request
import json


def format_json(d):
    return json.dumps(d, sort_keys=True, indent=2, ensure_ascii=False)

_api_base = 'https://absalon.ku.dk/api/v1/'

def _call_api(token, url_relative, **args):
    query_string = urllib.parse.urlencode(args).encode('utf-8')
    url = _api_base + url_relative
    headers = {
        'Authorization': 'Bearer ' + token
    }
    req = urllib.request.Request(url, data=query_string, method='GET',
                                 headers=headers)
    with urllib.request.urlopen(req) as f:
        data = json.loads(f.read().decode('utf-8'))
    return data

class Canvas:
    def __init__(self, token=None):
        if token is None:
            with open('token') as f:
                token = f.read().strip()
        self.token = token

    def api(self, url_relative, **args):
        return _call_api(self.token, url_relative, **args)

    def all_students(self, course_id):
        sections = self.api('courses/{}/sections'.format(course_id),
                            include='students')
        students = sections[0]['students']
        return students
