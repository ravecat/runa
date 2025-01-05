export default {
  timeout: null,
  mounted() {
    this.handleScroll = () => {
      if (!this.el) return;

      clearTimeout(this.timeout);

      this.timeout = setTimeout(() => {
        if (!this.el) return;

        const scrollPercent =
          (this.el.scrollTop / (this.el.scrollHeight - this.el.clientHeight)) *
          100;

        if (scrollPercent > 80) {
          this.pushEventTo(this.el, "load_more", {
            id: this.el.id,
          });
        }
      }, 200);
    };

    this.el.addEventListener("scroll", this.handleScroll);
  },
  destroyed() {
    this.el.removeEventListener("scroll", this.handleScroll);
    clearTimeout(this.timeout);
  },
};
