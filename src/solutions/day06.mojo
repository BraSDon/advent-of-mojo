from testing import assert_equal
from read import read

fn main() raises:
    var input = read(6)
    var example = read(6, True)

    assert_equal(part_one(example.value()), 4277556)
    assert_equal(part_one(input.value()), 4719804927602)

    assert_equal(part_two(example.value()), 3263827)
    assert_equal(part_two(input.value()), 9608327000261)

@fieldwise_init
struct Problem(Copyable, Movable):
    var nums: List[Int]
    var is_mul: Bool

    fn fold(self) -> Int:
        var result = self.nums[0]
        for i in range(1, len(self.nums)):
            if self.is_mul:
                result = result * self.nums[i]
            else:
                result = result + self.nums[i]
        return result

fn parse_ops(input: List[String]) raises -> List[Bool]:
    var ops = List[Bool]()
    var op_strings = input[-1].split()
    for op in op_strings:
        if op == "*":
            ops.append(True)
        elif op == "+":
            ops.append(False)
    return ops^

fn parse_nums_one(input: List[String]) raises -> List[List[Int]]:
    var nums = List[List[Int]]()
    for line in input[:-1]:
        nums.append([atol(i) for i in line.split()])
    return nums^

fn parse_nums_two(input: List[String]) raises -> List[List[Int]]:
    var nums = List[List[Int]]()
    var problem_nums = List[Int]()

    for col in range(len(input[0])):
        var s = ""
        for row in input[:-1]:
            s += row[col]
        if s.strip() == "":
            nums.append(problem_nums^)
            problem_nums = List[Int]()
        else:
            problem_nums.append(atol(s))
    nums.append(problem_nums^)
    return nums^

fn part_one(input: List[String]) raises -> Int:
    var nums = parse_nums_one(input)
    var ops = parse_ops(input)

    var problems = List[Problem]()
    for i in range(len(ops)):
        var elements = [n[i] for n in nums]
        problems.append(Problem(elements^, ops[i]))

    var count = 0
    for p in problems:
        count += p.fold()
    return count


fn part_two(input: List[String]) raises -> Int:
    var nums = parse_nums_two(input)
    var ops = parse_ops(input)
    var problems = List[Problem]()
    for i, elems in enumerate(nums):
        problems.append(Problem(elems.copy(), ops[i]))

    var count = 0
    for p in problems:
        count += p.fold()
    return count
