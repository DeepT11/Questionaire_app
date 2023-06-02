-- for creating unsername
CREATE OR REPLACE FUNCTION create_username() RETURNS trigger AS $create_username$

BEGIN

    UPDATE users 
    SET username = display_name || '#' || id
    WHERE id = NEW.id;
    
    RETURN NEW;
END;
$create_username$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER add_username
    AFTER INSERT ON users
    FOR EACH ROW
    EXECUTE FUNCTION create_username();


-- for mulitple posts
CREATE OR REPLACE FUNCTION getPosts(tags text[]) RETURNS TABLE(id INTEGER,
	excerpt_post_id INTEGER,
	wiki_post_id INTEGER,
	tag_name VARCHAR(255),
	count INTEGER) AS $printStrings$  
DECLARE  
   tag_num integer := array_length(tags, 1);  
   i integer := 2;  
BEGIN 
    CREATE TEMP TABLE temp(id INTEGER,
	excerpt_post_id INTEGER,
	wiki_post_id INTEGER,
	tag_name VARCHAR(255),
	count INTEGER)
    INSERT INTO temp (SELECT * FROM tags where tag_name = tags[1])
   WHILE i <= tag_num LOOP  
      INSERT INTO temp (SELECT * from temp intersect SELECT * FROM tags WHERE tag_name = tags[i]) ;
      i = i + 1;  
   END LOOP; 
   RETURN QUERY SELECT * FROM temp; 
END;  
$printStrings$ LANGUAGE plpgsql; 
