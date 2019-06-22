class Base():
    def __init__(self, x: int, y: int) -> None:
        self.x = x
        self.y = y


class Point(Base):
    def __init__(self, x: int, y: int) -> None:
        super().__init__(x, y)


def add(a: Base, b: Base) -> int:
    return a.x + a.y + b.x + b.y
