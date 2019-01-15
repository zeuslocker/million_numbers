defmodule MillionNumbers.Populator do
  @numbers_range 1..1000_000
  @chunk_size 100_000

  def start do
    {:ok, foo_conn} =
      Postgrex.start_link(
        hostname: "localhost",
        username: "postgres",
        password: "postgres",
        database: "foo"
      )

    Postgrex.query!(foo_conn, "DELETE FROM source", [])

    Enum.chunk_every(@numbers_range, @chunk_size)
    |> Enum.each(fn range ->
      Postgrex.query!(
        foo_conn,
        "INSERT INTO source (a, b, c) VALUES #{generate_values(range)}",
        []
      )
    end)

    IO.puts("Foo populated!")

    {:ok, bar_conn} =
      Postgrex.start_link(
        hostname: "localhost",
        username: "postgres",
        password: "postgres",
        database: "bar"
      )

    Postgrex.query!(bar_conn, "DELETE FROM dest", [])

    @numbers_range
    |> Enum.take_every(@chunk_size)
    |> Enum.each(fn tab ->
      Postgrex.transaction(foo_conn, fn conn ->
        query =
          Postgrex.prepare!(
            conn,
            "",
            "COPY (SELECT * FROM source LIMIT #{@chunk_size} OFFSET #{tab - 1}) TO STDOUT",
            []
          )

        stream = Postgrex.stream(conn, query, [])
        result_to_iodata = fn %Postgrex.Result{rows: rows} -> rows end
        Enum.into(stream, File.stream!("data"), result_to_iodata)
      end)

      Postgrex.transaction(bar_conn, fn conn ->
        stream = Postgrex.stream(conn, "COPY dest FROM STDIN", [])
        Enum.into(File.stream!("data"), stream)
      end)
    end)

    File.rm("data")
    IO.puts("Bar populated!")
  end

  defp generate_values(range) do
    range
    |> Enum.map(fn elem -> "(#{elem}, #{elem} % 3, #{elem} % 5)" end)
    |> Enum.join(", ")
  end

  def chunk_size, do: @chunk_size
  def numbers_range, do: @numbers_range
end
