mkdir -p docs

cp -r build/web/* docs/

git add . 
git commit -m "commit web"
git push origin master
