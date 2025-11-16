defmodule Rememcast.Html do
  @moduledoc """
  Utilities for working with HTML content.
  """

  @doc """
  Strips HTML tags from a string.

  Returns an empty string if the input is not a binary.

  ## Examples

      iex> Rememcast.Html.strip_html("<p>Hello <strong>world</strong></p>")
      "Hello world"

      iex> Rememcast.Html.strip_html(nil)
      ""
  """
  def strip_html(html) when is_binary(html) do
    Regex.replace(~r/<[^>]*>/, html, "")
  end

  def strip_html(_), do: ""
end
