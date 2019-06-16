from concurrent import futures
import time

import grpc

import route_guide_pb2
import route_guide_pb2_grpc

class RouteGuideServicer(route_guide_pb2_grpc.RouteGuideServicer):
    def GetFeature(self, request, context):
        return route_guide_pb2.Feature(name="sample", location=request)

def server():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    route_guide_pb2_grpc.add_RouteGuideServicer_to_server(
        RouteGuideServicer(), server
    )
    server.add_insecure_port('[::]:55051')
    server.start()
    try:
        while True:
            time.sleep(60 * 60 * 24)
    except KeyboardInterrupt:
        server.stop(0)


if __name__ == '__main__':
    server()
