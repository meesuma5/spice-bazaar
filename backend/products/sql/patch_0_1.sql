CREATE TABLE Users (
    user_id UUID PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    profile_picture BYTEA, 
    reg_date DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE Recipe (
    recipe_id UUID PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    ingredients VARCHAR(1000),
    instructions TEXT,
    cuisine TEXT,
    course TEXT,
    prep_time TIME,
    upload_date DATE NOT NULL DEFAULT CURRENT_DATE,
    user_id UUID NOT NULL,
    image VARCHAR(255),
    video_link VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE Reviews (
    review_id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    recipe_id UUID NOT NULL,
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date DATE NOT NULL DEFAULT CURRENT_DATE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (recipe_id) REFERENCES Recipe(recipe_id) ON DELETE CASCADE
);

CREATE TABLE Bookmarks (
    bookmark_id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    recipe_id UUID NOT NULL,
    bookmark_date DATE NOT NULL DEFAULT CURRENT_DATE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (recipe_id) REFERENCES Recipe(recipe_id) ON DELETE CASCADE
);