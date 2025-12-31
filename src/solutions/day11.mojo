from testing import assert_equal, assert_true
from read import read
from hashlib.hasher import Hasher

fn main() raises:
    var input = read(11)

    assert_equal(part_one(input.value()), 708)

    assert_equal(part_two(input.value()), 545394698933400)

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
    var reverse_mapping: Dict[Node, String]

    fn __init__(out self, var edges: List[InputEdges]) raises:
        self.edges = List[List[Node]](length=len(edges), fill=List[Node]())
        self.mapping = Dict[String, Node]()
        self.reverse_mapping = Dict[Node, String]()

        for i, s in enumerate(edges):
            self.mapping[s.from_] = UInt(i)
            self.reverse_mapping[UInt(i)] = s.from_
        self.mapping["out"] = UInt(len(edges))
        self.reverse_mapping[UInt(len(edges))] = "out"

        for e in edges:
            var from_ = self.mapping[e.from_]
            var to_list = [self.mapping.get(to_str).value() for to_str in e.to_list]
            self.edges[from_] = to_list^
        self.edges.append(List[Node]()) # "out" has no outgoing edges

    fn neighbors(self, node: Node) -> ref[self.edges] List[Node]:
        return self.edges[node]

    fn id_to_str(self, id: Node) -> Optional[String]:
        return self.reverse_mapping.get(id)

    fn start_id(self) -> Node:
        return self.mapping.get("you").value()

    fn svr_id(self) -> Node:
        return self.mapping.get("svr").value()

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

@fieldwise_init
struct State(Copyable, Movable, Hashable, EqualityComparable):
    var node: Node
    var fft: Bool
    var dac: Bool

    fn __eq__(self, other: State) -> Bool:
        return self.node == other.node and self.fft == other.fft and self.dac == other.dac

    fn __hash__[H: Hasher](self, mut hasher: H):
        hasher.update(self.node)
        hasher.update(self.fft)
        hasher.update(self.dac)

fn dfs(graph: Graph, start: Node, var fft: Bool, var dac: Bool, mut memo: Dict[State, Int]) raises -> Int:
    # count the paths from "svr" to "out" that pass through "fft" and "dac"
    var state = State(start, fft, dac)
    if state in memo:
        return memo[state]
    var str = graph.id_to_str(start).value()
    if str == "fft":
        fft = True
    if str == "dac":
        dac = True
    var path_count = 0
    for e in graph.neighbors(start):
        if e == graph.out_id():
            if fft and dac:
                path_count += 1
        else:
            path_count += dfs(graph, e, fft, dac, memo)
    memo[state^] = path_count
    return path_count

fn part_one(input: List[String]) raises -> Int:
    var parsed = parse_input(input)
    var graph = Graph(parsed^)
    return bfs(graph)

fn part_two(input: List[String]) raises -> Int:
    var parsed = parse_input(input)
    var graph = Graph(parsed^)
    var memo = Dict[State, Int]()
    return dfs(graph, graph.svr_id(), False, False, memo)
