import grpc

import route_guide_pb2
import route_guide_pb2_grpc


def guide_get_feature(stub):
    point = route_guide_pb2.Point(latitude=123, longitude=456)
    feature = stub.GetFeature(point)
    print(feature)


if __name__ == '__main__':
    with grpc.insecure_channel('localhost:55051') as channel:
        stub = route_guide_pb2_grpc.RouteGuideStub(channel)
        guide_get_feature(stub)
