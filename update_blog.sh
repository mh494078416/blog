echo "cd /home/pi/codeforfun.info"
cd /home/pi/codeforfun.info

echo "git pull"
git pull

echo "gor compile"
gor compile

echo "git add -A"
git add -A

echo "git commit -m 'update blog'"
git commit -m "update blog"

echo "git push origin master"
git push origin master


echo "cd compiled"
cd compiled

echo "git pull origin master"
git pull origin master

echo "git add -A"
git add -A 

echo "git commit -m 'update github blog'"
git commit -m "update github blog"

echo "git push origin master"
git push origin master


