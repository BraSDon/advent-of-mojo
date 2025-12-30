from testing import assert_equal, assert_true
from read import read

fn main() raises:
    var input = read(11)
    var example = read(11, True)

    assert_equal(part_one(example.value()), 5)
    assert_equal(part_one(input.value()), 962)

struct Edges[T: ImplicitlyCopyable & Copyable & Movable](Copyable, Movable):
    var from_: T
    var to_list: List[T]

    fn __init__(out self, from_: T, var to_list: List[T]):
        self.from_ = from_
        self.to_list = to_list^

alias Node = UInt
alias InputEdges = Edges[String]

struct Graph(Movable):
    var edges: List[List[Node]] # adjacency list
    var mapping: Dict[String, Node]

    fn __init__(out self, var edges: List[InputEdges]) raises:
        self.edges = List[List[Node]](length=len(edges), fill=List[Node]())
        self.mapping = Dict[String, Node]()

        for i, s in enumerate(edges):
            self.mapping[s.from_] = UInt(i)
        self.mapping["out"] = UInt(len(edges))

        for e in edges:
            var from_ = self.mapping[e.from_]
            var to_list = [self.mapping.get(to_str).value() for to_str in e.to_list]
            self.edges[from_] = to_list^
        self.edges.append(List[Node]()) # "out" has no outgoing edges

    fn neighbors(self, node: Node) -> ref[self.edges] List[Node]:
        return self.edges[node]

    fn start_id(self) -> Node:
        return self.mapping.get("you").value()

    fn out_id(self) -> Node:
        return self.mapping.get("out").value()

    fn num_nodes(self) -> Int:
        return len(self.edges)

fn parse_input(input: List[String]) raises -> List[InputEdges]:
    var parsed = List[InputEdges]()
    for line in input:
        var elems = line.split(":")
        var from_ = String(elems[0])
        var to_list = [String(x) for x in elems[1].split()]
        parsed.append(Edges(from_, to_list^))
    return parsed^

fn bfs(graph: Graph) raises -> Int:
    # perform BFS on graph and return amount of paths from "you" to "out"
    var n = graph.num_nodes()
    var curr_frontier = List[Node](capacity=n)
    var next_frontier = List[Node](capacity=n)

    var path_count = 0
    var start_id = graph.start_id()

    curr_frontier.append(start_id)

    while curr_frontier:
        for curr in curr_frontier:
            for neighbor in graph.neighbors(curr):
                if neighbor == graph.out_id():
                    path_count += 1
                    continue
                next_frontier.append(neighbor)
        swap(curr_frontier, next_frontier)
        next_frontier.clear()
    return path_count

fn part_one(input: List[String]) raises -> Int:
    var parsed = parse_input(input)
    var graph = Graph(parsed^)
    return bfs(graph)

fn part_two(input: List[String]) raises -> Int:
    return 0
