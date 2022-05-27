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

# recursively mutate the population
algorithm = fn population, algorithm ->
  # select current best solution, that with the highest fitness
  best = Enum.max_by(population, &Enum.sum/1)
  IO.write("\rCurrent Best: " <> Integer.to_string(Enum.sum(best)))

  if Enum.sum(best) == 1000 do
    Enum.sum(best)
  else
    population
    |> evaluate.()
    |> selection.()
    |> crossover.()
    |> algorithm.(algorithm)
  end
end

# run the algorithm
solution = algorithm.(population, algorithm)
IO.puts("\nAnswer is: #{inspect solution}")
