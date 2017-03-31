# coding: utf-8

import json


def decorator1(value):
    def receive_func(func):
        def wrapper(*args, **kwargs):
            print("Decorator1: value={}".format(value))
            (event, context) = args
            if event is None:
                event = {}
            event.update({"Decorator1": value})
            return func(event, context)
        return wrapper
    return receive_func


def decorator2(value):
    def receive_func(func):
        def wrapper(*args, **kwargs):
            print("Decorator2: value={}".format(value))
            return func(*args, **kwargs)
        return wrapper
    return receive_func


@decorator1("hoge")
@decorator2("fuga")
def run(event, context):
    print("Run: event={}".format(json.dumps(event)))


if __name__ == "__main__":
    run(None, None)
