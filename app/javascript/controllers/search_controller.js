import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "results", "message", "submit"]
  static values = { url: String }

  disconnect() {
    this.request?.abort()
  }

  async search(event) {
    event.preventDefault()

    this.request?.abort()
    const request = new AbortController()
    this.request = request

    const parameters = new URLSearchParams()

    for (const [name, value] of new FormData(this.formTarget)) {
      if (typeof value === "string" && value.trim() !== "") {
        parameters.set(name, value.trim())
      }
    }

    this.submitTarget.disabled = true
    this.resultsTarget.replaceChildren()
    this.resultsTarget.setAttribute("aria-busy", "true")
    this.messageTarget.className = "text-muted"
    this.messageTarget.textContent = "Searching..."

    try {
      const response = await fetch(
        `${this.urlValue}?${parameters.toString()}`,
        {
          headers: { Accept: "application/json" },
          signal: request.signal
        }
      )

      const body = await response.json()

      if (!response.ok) {
        throw new Error(body.error?.message || "Could not search listings.")
      }

      for (const listing of body.data) {
        this.resultsTarget.append(this.buildCard(listing))
      }

      this.messageTarget.textContent = body.data.length === 0
        ? "No listings match your search."
        : `${body.data.length} listing(s) found.`
    } catch (error) {
      if (error.name === "AbortError") return

      this.messageTarget.className = "alert alert-danger"
      this.messageTarget.textContent = error instanceof TypeError
        ? "Could not connect. Please try again."
        : error.message
    } finally {
      if (this.request === request) {
        this.submitTarget.disabled = false
        this.resultsTarget.setAttribute("aria-busy", "false")
      }
    }
  }

  buildCard(listing) {
    const column = document.createElement("div")
    column.className = "col-md-6 col-lg-4"

    const card = document.createElement("article")
    card.className = "card h-100"

    if (listing.photo_url) {
      const image = document.createElement("img")
      image.src = listing.photo_url
      image.alt = `Photo of ${listing.title}`
      image.className = "card-img-top"
      image.loading = "lazy"
      card.append(image)
    }

    const body = document.createElement("div")
    body.className = "card-body"

    const heading = document.createElement("h3")
    heading.className = "h5 card-title"

    const link = document.createElement("a")
    link.href = `/listings/${listing.id}`
    link.textContent = listing.title
    heading.append(link)

    const rent = new Intl.NumberFormat("es-CL", {
      style: "currency",
      currency: listing.currency,
      maximumFractionDigits: 0
    }).format(Number(listing.monthly_rent))

    body.append(
      heading,
      this.paragraph(`Neighborhood: ${listing.neighborhood.name}`),
      this.paragraph(`Monthly rent: ${rent}`),
      this.paragraph(`Available from: ${listing.available_from}`)
    )

    card.append(body)
    column.append(card)

    return column
  }

  paragraph(text) {
    const paragraph = document.createElement("p")
    paragraph.textContent = text
    return paragraph
  }
}