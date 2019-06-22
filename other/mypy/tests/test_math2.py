from math2 import add, Point


def test_add() -> None:
    a = Point(1, 2)
    b = Point(3, 4)
    assert add(a, b) == 10
