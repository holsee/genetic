defmodule Genetic.Algorithms.OneMax do
  @compile {:inline,
            [
              population_size: 0,
              max_fitness: 0,
              genotype: 0,
              fitness_function: 1
            ]}

  @spec population_size :: Genetic.population_size()
  def population_size, do: 100

  @spec max_fitness :: Genetic.fitness()
  def max_fitness, do: 1000

  @spec mutation_rate :: Genetic.mutation_rate()
  def mutation_rate, do: 5

  @spec genotype :: Genetic.chromosome()
  def genotype, do: for(_ <- 1..1000, do: Enum.random([0, 1]))

  @spec mutation_rate :: Genetic.mutation_rate()
  def fitness_function(chromosome), do: Enum.sum(chromosome)

  @spec crossover(Genetic.chromosome(), Genetic.chromosome()) :: list(Genetic.chromosome())
  defdelegate crossover(parent1, parent2), to: Genetic.Strategies.Crossover.SingleRandomPoint
end
