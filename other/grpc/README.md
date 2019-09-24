# gRPC sample

## Usage
```bash
# Generating client and server code
pipenv run python -m grpc_tools.protoc -I./ --python_out=. --grpc_python_out=. ./route_guide.proto

# Start server
pipenv run python route_guide_server.py

# Run client
pipenv run python route_guide_client.py
```

## References
- https://grpc.io/docs/tutorials/basic/python/
