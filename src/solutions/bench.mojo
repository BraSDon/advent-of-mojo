from benchmark import run, Unit, Report
from benchmark.compiler import keep
from read import read
import day01
import day02
import day03
import day04

fn main() raises:
    run_day[day01.part_one, day01.part_two](1)
    run_day[day02.part_one, day02.part_two](2)
    run_day[day03.part_one, day03.part_two](3)
    run_day[day04.part_one, day04.part_two](4)

fn run_day[
    part1_fn: fn(List[String]) raises -> Int,
    part2_fn: fn(List[String]) raises -> Int
](day: Int) raises:
    print("Day {}:".format(day))
    var i = read(day)
    var input = i.take()
    bench_part[part1_fn](input, 1)
    bench_part[part2_fn](input, 2)
    print("") # Newline

fn bench_part[
    func: fn(List[String]) raises -> Int,
](input: List[String], part: Int) raises:

    @parameter
    fn wrapper() raises:
        _ = keep(func(input))

    var unit = Unit.ms
    var report = run[wrapper](max_iters=10)
    var mean = report.mean(Unit.ms)
    print("  Part {}: {} {}".format(part, mean.__round__(4), unit))
