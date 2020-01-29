#!/bin/sh

RUN_R="Rscript --no-save --no-restore --no-site-file --no-init-file"

echo "============================ RAVE ==========================="
echo "Which application to launch? "
echo "  [m] Main application"
echo "  [p] Preprocess module"
echo "  [o] Settings"

read -p "Please enter letter [m], [p], or [o]. (Default is [m]): " USR_OPT

if [ -z $USR_OPT ]; then 
  USR_OPT="m" 
fi

case $USR_OPT in
  [oO]*)
    USR_OPT="o"
    break;;
  [pP]*)
    USR_OPT="p"
    break;;
  [mM]*)
    USR_OPT="m"
    break;;
  *)
    echo "Does not recognize your option. Default to [m]..."
esac


if [ $USR_OPT == "p" ]; then
  $RUN_R -e "rave::rave_preprocess()"
elif [ $USR_OPT == "o" ]; then
  $RUN_R -e "rave::rave_options()"
else 
  $RUN_R -e "rave::start_rave()"
fi


exit 0




