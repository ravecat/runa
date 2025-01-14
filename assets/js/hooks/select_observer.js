export const selectObserver = {
  mounted() {
    this.visibiltyObserver = new MutationObserver(
      this.handleVisibilityMutation
    );

    this.visibiltyObserver.observe(this.el, {
      attributes: true,
      attributeFilter: ["hidden", "aria-hidden"],
      attributeOldValue: true,
    });

    this.el.addEventListener("toggle", this.handleToggle.bind(this));
    this.el.addEventListener("close", this.handleClickOutside.bind(this));

    this.searchInput = document.getElementById(`${this.el.id}-input`);

    if (this.searchInput) {
      this.searchInput.addEventListener("input", this.handleSearch.bind(this));
    }
  },
  destroyed() {
    this.visibiltyObserver.disconnect();
    this.el.removeEventListener("close", this.handleClickOutside);
    this.el.removeEventListener("toggle", this.handleToggle);

    if (this.searchInput) {
      this.searchInput.removeEventListener("input", this.handleSearch);
    }
  },
  handleSearch(event) {
    let visibleOptionsCount = 0;

    const searchText = event.target.value.toLowerCase();

    this.el.querySelector("option[data-no-matches]")?.remove();

    for (const option of this.el.options) {
      const label = option.text.toLowerCase();

      if (label.includes(searchText)) {
        visibleOptionsCount++;
        option.style.display = "";
      } else {
        option.style.display = "none";
      }
    }

    if (visibleOptionsCount === 0) {
      const option = document.createElement("option");
      option.disabled = true;
      option.dataset.noMatches = "true";
      option.textContent = "No matches found";
      option.style.display = "";
      visibleOptionsCount = 2;

      this.el.insertBefore(option, this.el.firstChild);
    }

    this.el.size = visibleOptionsCount;
  },
  handleVisibilityMutation(mutations) {
    mutations.forEach((mutation) => {
      if (mutation.target === this.el) {
        const isOpen = mutation.target.getAttribute("aria-hidden") === "false";

        this.pushEventTo(this.el, isOpen ? "open_options" : "close_options", {
          id: this.el.id,
        });
      }
    });
  },
  handleToggle() {
    const shevron = document.getElementById(`${this.el.id}-shevron`);

    shevron?.classList.toggle("rotate-180");
    this.el.classList.toggle("hidden");

    const isOpen = this.el.getAttribute("aria-hidden") === "false";

    this.el.setAttribute("aria-hidden", isOpen ? "true" : "false");
  },
  handleClickOutside() {
    const shevron = document.getElementById(`${this.el.id}-shevron`);

    const isOpen = this.el.getAttribute("aria-hidden") === "false";

    if (isOpen) {
      this.el.setAttribute("aria-hidden", "true");
      this.el.classList.add("hidden");
      shevron.classList.remove("rotate-180");
    }
  },
};
