THEOS_PACKAGE_DIR_NAME = debs
TARGET = :clang
ARCHS=armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = GesturesPlus
GesturesPlus_FILES = GesturesPlus.xm
GesturesPlus_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
