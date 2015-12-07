# mogenerator is a command-line tool that, given an .xcdatamodel file,
# will generate two classes per entity. The first class, _MyEntity,
# is intended solely for machine consumption and will be continuously
# overwritten to stay in sync with your data model. The second class,
# MyEntity, subclasses _MyEntity, won't ever be overwritten and is a
# great place to put your custom logic.
#
# https://github.com/rentzsch/mogenerator
#

mogenerator --v2 --model ${PROJECT_DIR}/${PROJECT}/XTDiscountAsciiWarehouse.xcdatamodeld -O ${PROJECT_DIR}/${PROJECT}/CoreData -M ${PROJECT_DIR}/${PROJECT}/CoreData/Machine