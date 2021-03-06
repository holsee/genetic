# Genetic algorithm for the one-max problem
#   Starting with a random distribution of bitstrings introduces
#   solutions with sufficiently different characteristics.
#   This helps to avoid premature convergence.
population = for _ <- 1..100, do: for(_ <- 1..1000, do: Enum.random(0..1))

evaluate = fn population ->
  # sort population by sum in descending order
  Enum.sort_by(population, &Enum.sum/1, &>=/2)
end

selection = fn population ->
  population
  |> Enum.chunk_every(2)
  |> Enum.map(&List.to_tuple(&1))
end

crossover = fn population ->
  population
  |> Enum.reduce(
    [],
    fn {p1, p2}, acc ->
      # extract individual chromosomes for each parent
      # crossover point is a uniformly distributed random number
      cx_point = :rand.uniform(1000)
      # create new child from p1 and p2
      {{h1, t1}, {h2, t2}} = {
        Enum.split(p1, cx_point),
        Enum.split(p2, cx_point)
      }
      # recombine with tails swapped to create new child
      # known as single-point crossover
      [h1 ++ t2, h2 ++ t1 | acc]
    end
  )
end

mutation = fn population ->
  # Doing this actually preserves the fitness of the chromosome;
  # however, it also prevents the parents from becoming too similar
  # before they crossover.
  population
  |> Enum.map(
    fn chromosome ->
      # 5% probability of mutation
      if :rand.uniform() < 0.05 do
        Enum.shuffle(chromosome)
      else
        chromosome
      end
    end
  )
end

# recursively mutate the population
algorithm = fn population, algorithm, generation ->
  # select current best solution, that with the highest fitness
  best =
    population
    |> Enum.max_by(&Enum.sum/1)
    |> Enum.sum()

  IO.write(
    "\r[gen: " <> Integer.to_string(generation) <> "]" <>
    " Current Best: " <> Integer.to_string(best)
  )

  if best == 1000 do
    best
  else
    population
    |> evaluate.()
    |> selection.()
    |> crossover.()
    |> mutation.()
    |> algorithm.(algorithm, generation + 1)
  end
end

# run the algorithm
solution = algorithm.(population, algorithm, 0)
IO.puts("\nAnswer is: #{inspect solution}")
