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

export type Member = {
    id: string;
    role: string;
    inserted_at: string;
    updated_at: string;
    user: User;
}