from testing import assert_equal, assert_true
from read import read

fn main() raises:
    var input = read(4)
    var example = read(4, True)

    assert_equal(part_one(example.value()), 13)
    assert_equal(part_one(input.value()), 1367)

    assert_equal(part_two(example.value()), 43)
    assert_equal(part_two(input.value()), 9144)

@fieldwise_init
struct Grid(Stringable, Copyable, Movable):
    var cells: List[List[Bool]]

    @implicit
    fn __init__(out self, input: List[String]) raises:
        self.cells = List[List[Bool]]()
        for line in input:
            var row = List[Bool]()
            for char in line.codepoints():
                row.append(char == Codepoint.ord("@"))
            self.cells.append(row^)
        self._assert_rectangular()

    fn _assert_rectangular(self) raises -> None:
        var row_length = len(self.cells[0])
        for row in self.cells:
            assert_equal(len(row), row_length)

    fn true_neighbors(self, x: Int, y: Int) -> Int:
        # Returns the number of adjacent True cells (up, down, left, right, diagonals)
        adjacent_coords = [
            (x - 1, y - 1), (x, y - 1), (x + 1, y - 1),
            (x - 1, y),                 (x + 1, y),
            (x - 1, y + 1), (x, y + 1), (x + 1, y + 1)
        ]
        count = 0
        for (nx, ny) in adjacent_coords:
            if 0 <= nx < len(self.cells[ny]) and 0 <= ny < len(self.cells):
                if self.cells[ny][nx]:
                    count += 1
        return count

    fn moveable(self) -> Grid:
        # Returns a grid indicating which cells are moveable (i.e. have less than 4 adjacent True cells)
        var moveable_cells = List[List[Bool]]()
        for y in range(len(self.cells)):
            var row = List[Bool]()
            for x in range(len(self.cells[y])):
                row.append(self.true_neighbors(x, y) < 4 and self.cells[y][x])
            moveable_cells.append(row^)
        return Grid(cells=moveable_cells^)

    fn elements(self) -> Int:
        var count = 0
        for row in self.cells:
            for cell in row:
                if cell:
                    count += 1
        return count

    fn __str__(self) -> String:
        var lines = List[String]()
        for row in self.cells:
            var line = ""
            for cell in row:
                line += "@" if cell else "."
            lines.append(line)
        return "\n".join(lines^)

    fn clean(mut self) -> Bool:
        var changed = False
        for y in range(len(self.cells)):
            for x in range(len(self.cells[y])):
                var new = self.cells[y][x] and self.true_neighbors(x, y) >= 4
                if not changed and (new != self.cells[y][x]):
                    changed = True
                self.cells[y][x] = new
        return changed


fn part_one(input: List[String]) raises -> Int:
    var parsed = Grid(input)
    return parsed.moveable().elements()

fn part_two(input: List[String]) raises -> Int:
    var parsed = Grid(input)
    var start_elements = parsed.elements()
    while parsed.clean():
        pass
    return start_elements - parsed.elements()
