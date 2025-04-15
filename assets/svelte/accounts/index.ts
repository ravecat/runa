export type User = {
    id: string;
    name: string;
    email: string;
    avatar: string;
    nickname: string;
    uid: string;
    inserted_at: string;
    updated_at: string;
}

export type Contributor = {
    id: string;
    role: "owner" | "admin" | "editor" | "viewer";
    user: User;
    inserted_at: string;
    updated_at: string;
}