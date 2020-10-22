population = for _ <- 1..100, do: for _ <- 1..40, do: Enum.random(0..1)

evaluate = fn population ->
  Enum.sort_by(population, &Enum.sum/1, &>=/2)
end
selection = fn population ->
  population
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
end
crossover = fn population ->
  Enum.reduce(population, [],
    fn {p1, p2}, acc ->
      cx_point = :rand.uniform(42)
      {{h1, t1}, {h2, t2}} = {
        Enum.split(p1, cx_point),
        Enum.split(p2, cx_point),
      }
      [h1 ++ t2 | [h2 ++ t1 | acc ]]
    end)
end

algorithm =
  fn population, algorithm ->
    best = Enum.max_by(population, &Enum.sum/1)
    IO.write("\rCurrent Best: " <> Integer.to_string(Enum.sum(best)) )
    if Enum.sum(best) == 42 do
      best
    else
      population
        |> evaluate.()
        |> selection.()
        |> crossover.()
        |> algorithm.(algorithm)
    end
  end

solution = algorithm.(population, algorithm)
IO.write("\n Answer is \n")
IO.inspect(solution)
