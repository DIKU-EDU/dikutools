import time
import collections

'''
A method for caching method calls.
'''

def in_one_hour():
    return time.time() + 60 * 60

cached_data = {}
def cache(name, data_fun,
          expiration_time=None, size_limit=100000):
    if expiration_time is None:
        expiration_time = in_one_hour()

    try:
        block = cached_data[name]
    except KeyError:
        data = data_fun()
        if len(data) <= size_limit:
            cached_data[name] = (data, expiration_time)
        return data
    else:
        data_r, expiration_time_r = block
        if time.time() > expiration_time_r:
            del cached_data[name]
            return cache(name, data_fun, expiration_time)
        else:
            return data_r

class CachedClass(object):
    def __init__(self, thing):
        object.__setattr__(self, 'thing', thing)

    def __getattr__(self, name):
        val = self.thing.__getattribute__(name)
        if isinstance(val, collections.Callable):
            def proxy_fun(*args, **kwargs):
                identifier = str((name, args, kwargs))
                data_fun = lambda: val(*args, **kwargs)
                return cache(identifier, data_fun)
            return proxy_fun
        else:
            return val

    def __setattr__(self, name, val):
        self.thing.__setattr__(name, val)
