defmodule Genetic do
  @type population :: list()
  @type population_size :: non_neg_integer()
  @type chromosome :: list()
  @type genotype :: (() -> chromosome())
  @type fitness :: integer()
  @type fitness_function :: (chromosome() -> fitness())
  @type algorithm :: module()
  @type mutation_rate :: non_neg_integer()

  @spec run(algorithm) :: chromosome
  def run(algo) do
    population = initialize(algo)
    evolve(population, algo)
  end

  @spec initialize(algorithm) :: population
  def initialize(algo) do
    population_size = algo.population_size()
    for _ <- 1..population_size, do: algo.genotype()
  end

  @spec evolve(population, algorithm, generation :: integer()) :: population
  def evolve(population, algo, generation \\ 0) do
    [{best, best_fitness} | _] = population_eval = evaluate(population, algo)
    IO.write("\rAlgo: #{algo} | MutRate: #{algo.mutation_rate()}% | Generation: #{generation} | Fitness: #{best_fitness}")

    if best_fitness >= algo.max_fitness() do
      best
    else
      population =
        population_eval
        |> Enum.map(&elem(&1, 0))

      population
      |> select()
      |> crossover(algo)
      |> mutation(algo)
      |> evolve(algo, generation + 1)
    end
  end

  @spec evaluate(population, algorithm) :: list({chromosome, fitness})
  def evaluate(population, algo) do
    population
    |> Enum.map(&{&1, algo.fitness_function(&1)})
    |> Enum.sort_by(fn {_, fitness} -> fitness end, &>=/2)
  end

  @spec select(population) :: population
  def select(population) do
    population
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple(&1))
  end

  @spec crossover(population, algorithm) :: population
  def crossover(population, algo) do
    Enum.reduce(population, [], fn {p1, p2}, acc ->
      [ch0, ch1] = algo.crossover(p1, p2)
      [ch0, ch1 | acc]
    end)
  end

  @spec mutation(population, algorithm) :: chromosome
  def mutation(population, algo) do
    mutation_rate = algo.mutation_rate()

    Enum.map(population, fn chromosome ->
      if :rand.uniform(100) <= mutation_rate do
        Enum.shuffle(chromosome)
      else
        chromosome
      end
    end)
  end
end
