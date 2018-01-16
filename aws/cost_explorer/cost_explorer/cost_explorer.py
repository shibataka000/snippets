# coding: utf-8

import json

import boto3


def get_services():
    time_period_start = "2017-01-01"
    time_period_end = "2018-01-01"

    client = boto3.client("ce", region_name="us-east-1")

    r = client.get_cost_and_usage(
        TimePeriod={
            "Start": time_period_start,
            "End": time_period_end
        },
        Granularity="MONTHLY",
        Metrics=["UnblendedCost"],
        GroupBy=[
            {
                "Type": "DIMENSION",
                "Key": "SERVICE"
            }
        ]
    )
    results_by_time = r["ResultsByTime"]

    services = []
    for data_monthly in results_by_time:
        services += [item["Keys"][0] for item in data_monthly["Groups"]]
    services = list(sorted(list(set(services))))

    return services


def get_cost(year, month, services, tags=[]):
    def get_period(year, month):
        if month <= 0:
            return get_period(year - 1, month + 12)
        elif month >= 13:
            return get_period(year + 1, month - 12)
        else:
            return "{0:02}-{1:02}-01".format(year, month)

    def get_services_filter(service):
        return {
            "Dimensions": {
                "Key": "SERVICE",
                "Values": services
            }
        }

    def get_tag_filter(tag):
        return {
            "Tags": {
                "Key": tag[0],
                "Values": tag[1]
            }
        }

    def get_tags_filter(tags):
        if len(tags) == 1:
            return get_tag_filter(tags[0])
        else:
            return {
                "And": [get_tag_filter(tag) for tag in tags]
            }

    def get_filter(services, tags):
        if tags:
            return {
                "And": [
                    get_services_filter(services),
                    get_tags_filter(tags)
                ]
            }
        else:
            return get_services_filter(services)

    time_period_start = get_period(year, month)
    time_period_end = get_period(year, month + 1)
    _filter = get_filter(services, tags)

    client = boto3.client("ce", region_name="us-east-1")

    r = client.get_cost_and_usage(
        TimePeriod={
            "Start": time_period_start,
            "End": time_period_end
        },
        Granularity="MONTHLY",
        Metrics=["UnblendedCost"],
        Filter=_filter,
        GroupBy=[
            {
                "Type": "DIMENSION",
                "Key": "SERVICE"
            }
        ]
    )
    results_by_time = r["ResultsByTime"]
    groups = results_by_time[0]["Groups"]

    costs = {service: 0 for service in services}
    for x in groups:
        service = x["Keys"][0]
        cost = float(x["Metrics"]["UnblendedCost"]["Amount"])
        costs[service] = cost

    return costs


if __name__ == "__main__":
    services = get_services()
    print("## Used services in 2017")
    print(json.dumps(services, indent=4))

    print("## Cost in 2017/12")
    costs = get_cost(2017, 12, services)
    print(json.dumps(costs, indent=4))
