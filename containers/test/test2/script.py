import math
import multiprocessing
import time
import random

# Amount of work per process (increase for heavier benchmarks)
ITERATIONS = 87_654_321


def cpu_work(n):
    x = 0.0001 * random.random()
    for _ in range(n):
        x = math.sqrt(x * x + 1)
    return x  # return value prevents optimization


def worker(n, return_dict, idx):
    start = time.perf_counter()
    cpu_work(n)
    end = time.perf_counter()
    return_dict[idx] = end - start


if __name__ == "__main__":
    cores = multiprocessing.cpu_count() - 1  # Reserve one core for system
    print(f"Running benchmark on {cores} cores...")

    manager = multiprocessing.Manager()
    results = manager.dict()
    processes = []

    for i in range(cores):
        p = multiprocessing.Process(target=worker, args=(ITERATIONS, results, i))
        p.start()
        processes.append(p)

    for p in processes:
        p.join()

    # Aggregate results
    times = list(results.values())
    total_time = max(times)  # wall-clock time
    ops = ITERATIONS * cores
    ops_per_sec = ops / total_time

    print("=== CPU Benchmark Results ===")
    print(f"Total operations: {ops:,}")
    print(f"Wall time: {total_time:.3f} seconds")
    print(f"Throughput: {ops_per_sec:,.0f} ops/sec")
    print(f"Per-core times: {[round(t, 3) for t in times]}")
    print("================================")
