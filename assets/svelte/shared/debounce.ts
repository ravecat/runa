export function debounce(func: Function, delay: number) {
    let timeout: ReturnType<typeof setTimeout>;

    return function executedFunction(...args) {
        clearTimeout(timeout);

        const later = () => {
            func(...args);
        };

        timeout = setTimeout(later, delay);
    };
}