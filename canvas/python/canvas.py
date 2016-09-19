import urllib.parse
import urllib.request
import json


def format_json(d):
    return json.dumps(d, sort_keys=True, indent=2, ensure_ascii=False)

_api_base = 'https://absalon.ku.dk/api/v1/'

def _call_api(token, method, url_relative, **args):
    try:
        args = args['_arg_list']
    except KeyError:
        pass
    query_string = urllib.parse.urlencode(args, safe='[]@', doseq=True).encode('utf-8')
    url = _api_base + url_relative
    headers = {
        'Authorization': 'Bearer ' + token
    }
    req = urllib.request.Request(url, data=query_string, method=method,
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

    def get(self, url_relative, **args):
        return _call_api(self.token, 'GET', url_relative, **args)

    def post(self, url_relative, **args):
        return _call_api(self.token, 'POST', url_relative, **args)

    def put(self, url_relative, **args):
        return _call_api(self.token, 'PUT', url_relative, **args)

    def all_students(self, course_id):
        sections = self.get('courses/{}/sections'.format(course_id),
                            include='students')
        students = sections[0]['students']
        return students

    def group_categories(self, course_id):
        return self.get('courses/{}/group_categories'.format(course_id))

    def create_group(self, group_category_id, name):
        return self.post('group_categories/{}/groups'.format(group_category_id),
                         name=name, join_level='invitation_only')

    def add_group_members(self, group_id, members):
        args = {
            'members[]': members
        }
        return self.put('groups/{}'.format(group_id), **args)
