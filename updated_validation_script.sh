#/bin/bash
echo -e "\n#######################Python Package validation#################\n"

rm -rf Newpackages_list.txt
rm -rf packages_list.txt

pip3 list --format=columns | awk 'NR>2 {print $1}' > Newpackages_list.txt
sort Newpackages_list.txt -o Newpackages_list.txt
aws s3 cp s3://med-av-daas-preprod-datasci-cicd/emr/bootstrap/local.3.7.requirements_grv.txt ~
cut -d "=" -f1 local.3.7.requirements_grv.txt > packages_list.txt
sort packages_list.txt -o packages_list.txt
comm -23 packages_list.txt Newpackages_list.txt > /tmp/unmatched_packages.log
Package_comp=$(cat /tmp/unmatched_packages.log)
if [ -z "$Package_comp" ];
then
echo -e "\n-------------All packages are matched---------------\n"
else
echo -e "\n-------------Packages are not matched---------------\n"
echo -e "$Package_comp"
fi
comm -23 Newpackages_list.txt packages_list.txt > /tmp/New_packages.log
NewPackages_comp=$(cat /tmp/New_packages.log)
if [ -z "$NewPackages_comp" ];
then
echo -e "\n-------------No packages were added in New cluster---------------\n"
else
echo -e "\n-------------New packages were added to the cluster---------------\n"
echo -e "$NewPackages_comp"
fi
# echo -e "#########################Importing the packages####################"
# Python_packages="Newpackages_list.txt"
# # Read packages from file into an array
# readarray -t packages < "$Python_packages"
 
# # Loop through each package
# for pkg in "${packages[@]}"
# do
#     if python -c "import $pkg" >/dev/null 2>&1; then
#         echo "$pkg Package imported successfully."
#     else
#         echo "$pkg Package is not imported."
#     fi
# done
# List of packages to check
Python_packages="Newpackages_list.txt"
# Read packages from file into an array
readarray -t packages < "$Python_packages"
for pkg in "${packages[@]}"
do
    if pip show "$pkg" > /dev/null 2>&1; then
        echo "$pkg is installed."
    else
        echo "$pkg is not installed."
    fi
done