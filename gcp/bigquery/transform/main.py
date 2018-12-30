import json
import re
from functools import reduce

import click


def unique(list_):
    return list(sorted(list(set(list_))))


def merge_str(a, b):
    merged = merge(json.loads(a), json.loads(b))
    return json.dumps(merged)


def merge(a, b):
    if type(a) == type(b):
        if isinstance(a, dict):
            keys = unique(list(a.keys()) + list(b.keys()))
            return {key: merge(a.get(key), b.get(key))
                    for key in keys}
        if isinstance(a, list):
            return a + b
        return a
    else:
        for type_ in [dict, list]:
            if isinstance(a, type_):
                return a
            if isinstance(b, type_):
                return b
        if a is None:
            return b
        if b is None:
            return a
        assert False


def get_schema(key, value, mode="NULLABLE"):
    if isinstance(value, dict):
        if not value:
            value = {"dummy": ""}
        fields = [get_schema(k, v) for k, v in value.items()]
        return {
            "mode": mode,
            "name": key,
            "type": "RECORD",
            "fields": fields
        }
    elif isinstance(value, list):
        if value:
            type_ = type(value[0])
            assert all([isinstance(x, type_) for x in value])
            return get_schema(key, value[0], "REPEATED")
        else:
            return get_schema(key, None, "REPEATED")
    else:
        return {
            "mode": mode,
            "name": key,
            "type": get_type(value)
        }


def get_type(value):
    if isinstance(value, str):
        patterns = [
            ("^\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:\d{2}", "TIMESTAMP"),
            # ("^\d{4}\-\d{2}\-\d{2}", "DATE"),
            # ("^\d+\.\d+$", "FLOAT"),
            # ("^\d+$", "INTEGER"),
            # ("^(true|false)$", "BOOL"),
        ]
        for (pattern, type_) in patterns:
            if re.match(pattern, value):
                return type_
        return "STRING"
    elif isinstance(value, bool):
        return "BOOL"
    elif isinstance(value, int):
        return "INTEGER"
    elif isinstance(value, float):
        return "FLOAT"
    else:
        return "STRING"


def get_template(schema):
    template = {}
    for elem in schema:
        if elem["type"] == "RECORD":
            value = get_template(elem["fields"])
        else:
            value = None
        if elem["mode"] == "REPEATED":
            value = [value] if value else []
        template[elem["name"]] = value
    return template


def trim(schema, data):
    template = get_template(schema)
    return merge(template, data)


def print_json(data):
    print(json.dumps(data, indent=4))


@click.command()
@click.argument("in_data_file")
@click.argument("out_schema_file")
@click.argument("out_data_file")
def main(in_data_file, out_schema_file, out_data_file):
    with open(in_data_file) as f:
        merged = json.loads(reduce(merge_str, f))
    schema = get_schema("schema", merged)["fields"]
    with open(out_schema_file, "w") as f:
        f.write(json.dumps(schema, indent=4))
    with open(in_data_file) as fin, open(out_data_file, "w") as fout:
        for row in fin:
            trimmed = trim(schema, json.loads(row))
            fout.write(json.dumps(trimmed))
            fout.write("\n")


if __name__ == "__main__":
    main()
