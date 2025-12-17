from testing import assert_equal
from read import read

fn main() raises:
    var input = read(7)
    var example = read(7, True)

    assert_equal(part_one(example.value()), 21)
    assert_equal(part_one(input.value()), 1681)

    assert_equal(part_two(example.value()), 40)
    assert_equal(part_two(input.value()), 422102272495018)

@fieldwise_init
struct Grid:
    var cells: List[List[Int]]
    var width: Int
    var height: Int
    var splitters_hit: Int
    comptime splitter = -1

    fn __init__(out self, input: List[String]) raises:
        self.height = len(input)
        self.width = len(input[0]) if self.height > 0 else 0
        self.cells = List[List[Int]](capacity=self.height)
        self.splitters_hit = 0
        for row in range(self.height):
            var cells_row = List[Int](length=self.width, fill=0)
            for col in range(self.width):
                char = input[row][col]
                if char == "^":
                    cells_row[col] = self.splitter
                    continue
                if char == "S":
                    cells_row[col] = 1
            self.cells.append(cells_row^)

    fn run(mut self):
        for row in range(1, self.height):
            for col in range(self.width):
                var above_val = self.cells[row - 1][col]
                if above_val >= 1:
                    if self.cells[row][col] == self.splitter:
                        self.cells[row][col - 1] += above_val
                        self.cells[row][col + 1] += above_val
                        self.splitters_hit += 1
                    else:
                        self.cells[row][col] += above_val

    fn paths(self) -> Int:
        var count = 0
        for i in self.cells[-1]:
            count += i
        return count

fn part_one(input: List[String]) raises -> Int:
    var parsed = Grid(input)
    parsed.run()
    return parsed.splitters_hit

fn part_two(input: List[String]) raises -> Int:
    var parsed = Grid(input)
    parsed.run()
    return parsed.paths()
