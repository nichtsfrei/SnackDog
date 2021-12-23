#ifndef __BARFCAL_H
#define __BARFCAL_H

#define ANIMAL_PERCENTAGE 0.8
#define HERBAL_PERCENTAGE 0.2
/**
 * @brief Is used to set the multiplier for animal based food
 *
 * The first value of the X macro is defining the enum name, the second the
 * actual multiplier and the third the string representation.
 *
 */
#define BCD_ANIMAL                                                             \
	X(bcd_animal_scallop, 0.5, "scallop")                                  \
	X(bcd_animal_rumen, 0.2, "rumen")                                      \
	X(bcd_animal_insides, 0.15, "insides")                                 \
	X(bcd_animal_bones, 0.15, "raw meaty bones")

/**
 * @brief Is used to set the multiplier for herbal based food
 *
 * The first value of the X macro is defining the enum name, the second the
 * actual multiplier and the third the string representation.
 *
 */
#define BCD_HERBAL                                                             \
	X(bcd_herbal_vegetables, 0.8, "vegetables")                            \
	X(bcd_herbal_fruits, 0.2, "fruits")

/**
 * @brief Is used to set the multiplier based on activity level
 *
 * The first value of the X macro is defining the enum name, the second the
 * actual multiplier and the third the string representation.
 *
 */
#define BCD_EXTRA_MULTIPLIER                                                   \
	X(bcd_emf_low, 1.0, "low activity")                                    \
	X(bcd_emf_low_middle, 1.25, "low_middle activity")                     \
	X(bcd_emf_middle, 1.5, "middle activity")                              \
	X(bcd_emf_middle_high, 1.75, "middle_high activity")                   \
	X(bcd_emf_high, 2.0, "high activity")                                  \
	X(bcd_emf_very_high, 2.5, "very_high activity")                        \
	X(bcd_emf_old, 0.9, "old")                                             \
	X(bcd_emf_nautered, 0.9, "nautered")

/**
 * @brief Is used to set the multiplier for supplements
 *
 * The first value of the X macro is defining the enum name, the second the
 * actual multiplier and the third the string representation.
 *
 */
#define BCD_SUPPLEMENT                                                         \
	X(bcd_supplement_unset, 0.0, "ignored")                                \
	X(bcd_supplement_algae_powder, 0.00000463, "algae powder")             \
	X(bcd_supplement_cod_liver_oil, 0.00000463, "cod liver oil")           \
	X(bcd_supplement_fat, 0.15, "fat")                                     \
	X(bcd_supplement_oil, 0.0000093, "oil with omega 3")

/**
 * @brief Is used to define span units
 *
 * The first value of the X macro is defining the enum name, the second the
 * string representation.
 *
 */
#define BCD_SPAN_UNIT                                                          \
	X(bcd_day, "day")                                                      \
	X(bcd_week, "week")                                                    \
	X(bcd_month, "month")                                                  \
	X(bcd_year, "year")

/**
 * @brief Is used to define weight units
 *
 * The first value of the X macro is defining the enum name, the second the
 * string representation.
 *
 */
#define BCD_WEIGHT_UNIT                                                        \
	X(bcd_micro_gram, "μg")                                                \
	X(bcd_milli_gram, "mg")                                                \
	X(bcd_gram, "g")                                                       \
	X(bcd_kilo_gram, "kg")                                                 \
	X(bcd_micro_liter, "μl")                                               \
	X(bcd_milli_liter, "ml")                                               \
	X(bcd_liter, "l")                                                      \
	X(bcd_kilo_liter, "kl")

/**
 * @brief Is used to define dog sizes
 *
 * The first value of the X macro is defining the enum name, the second the
 * string representation.
 *
 */
#define BCD_DOG_SIZE                                                           \
	X(bcd_dog_small, "small")                                              \
	X(bcd_dog_medium, "medium")                                            \
	X(bcd_dog_large, "large")

/**
 * @brief defines the animal enum
 *
 * It is based on BCD_ANIMAL and represents animal based food
 */
enum bcd_animal_type {
#define X(a, b, c) a,
	BCD_ANIMAL
#undef X
};

/**
 * @brief defines the herbal enum
 *
 * It is based on BCD_HERBAL and represents herbal based food
 */
enum bcd_herbal_type {
#define X(a, b, c) a,
	BCD_HERBAL
#undef X
};

/**
 * @brief defines the supplements enum
 *
 * It is based on BCD_SUPPLEMENT and represents supplements based food
 */
enum bcd_supplement_type {
#define X(a, b, c) a,
	BCD_SUPPLEMENT
#undef X
};

/**
 * @brief defines the weight unit enum
 *
 * It is based on BCD_WEIGHT_UNIT and represents used weight units
 */
enum bcd_weight_unit {
#define X(a, b) a,
	BCD_WEIGHT_UNIT
#undef X
};

/**
 * @brief defines the span unit enum
 *
 * It is based on BCD_SPAN_UNIT and represents used span units
 */
enum bcd_span_unit {
#define X(a, b) a,
	BCD_SPAN_UNIT
#undef X
};

/**
 * @brief defines the dog sizes
 *
 * It is based on BCD_DOG_SIZE and represents dog sizes
 */
enum bcd_dog_size {
#define X(a, b) a,
	BCD_DOG_SIZE
#undef X
};

/**
 * @brief defines the extra multiplier
 *
 * It is based on BCD_EXTRA_MULTIPLIER and represents extra multiplier
 */
enum bcd_extra_multiplier {
#define X(a, b, c) a,
	BCD_EXTRA_MULTIPLIER
#undef X
};

/**
 * @brief contains information about animal based ingredient
 *
 * - type; is used to determine the type of animal based ingredient
 * - amount; the amount of ingredient
 * - weight_unit; the measurement unit of amount
 */
struct bcd_animal_recommendation {
	enum bcd_animal_type type;
	enum bcd_weight_unit weight_unit;
	float amount;
};

struct bcd_animal_recommendations {
	unsigned int len;
	unsigned int cap;
	struct bcd_animal_recommendation *recommendations;
};

/**
 * @brief contains information about herbal based ingredient
 *
 * - type; is used to determine the type of herbal based ingredient
 * - amount; the amount of ingredient
 * - weight_unit; the measurement unit of amount
 */
struct bcd_herbal_recommendation {
	enum bcd_herbal_type type;
	enum bcd_weight_unit weight_unit;
	float amount;
};

struct bcd_herbal_recommendations {
	unsigned int len;
	unsigned int cap;
	struct bcd_herbal_recommendation *recommendations;
};

/**
 * @brief contains information about supplement
 *
 */
struct bcd_supplement_recommendation {
	enum bcd_supplement_type type; ///< Kind of supplement
	enum bcd_weight_unit weight_unit; ///< Weight unit of supplement
	float amount; ///< Amount of supplement
};
/**
 * @brief contains multiple supplement recommendations
 */
struct bcd_supplement_recommendations {
	unsigned int len;
	unsigned int cap;
	struct bcd_supplement_recommendation *recommendations;
};

/**
 * @brief holds animal, herbal and supplements recommendations normalized per
 * span
 */
struct bcd_recommendation {
	unsigned int span;
	enum bcd_span_unit span_unit;
	struct bcd_supplement_recommendations *supplements;
	struct bcd_animal_recommendations *animal;
	struct bcd_herbal_recommendations *herbal;
};

struct bcd_recommendations {
	unsigned int len;
	unsigned int cap;
	struct bcd_recommendation *recommendations;
};

struct bcd_dog {
	enum bcd_dog_size size;
	unsigned int age;
	enum bcd_span_unit age_unit;
	float weight;
	enum bcd_weight_unit weight_unit;
	unsigned int activity_level_in_hours;
	int is_nautered;
	int is_old;
};

struct bcd_algae_powder {
	unsigned int jod;
	unsigned int per;
	enum bcd_weight_unit jod_weight_unit;
	enum bcd_weight_unit per_unit;
};

struct bcd_portions {
	unsigned int span;
	enum bcd_span_unit span_unit;
	unsigned int portions;
	enum bcd_span_unit portions_per;
	struct bcd_recommendations *recommendations;
};

float bcd_animal_type_severity(enum bcd_animal_type);

char *bcd_animal_type_string(enum bcd_animal_type);

char *bcd_weight_unit_string(enum bcd_weight_unit);

char *bcd_span_unit_string(enum bcd_span_unit);

float bcd_herbal_type_severity(enum bcd_herbal_type);

char *bcd_herbal_type_string(enum bcd_herbal_type);

float bcd_supplement_type_severity(enum bcd_supplement_type);

char *bcd_supplement_type_string(enum bcd_supplement_type);

float bcd_extra_multiplier_severity(enum bcd_extra_multiplier);

char *bcd_extra_multiplier_string(enum bcd_extra_multiplier);

float bcd_dog_size_severity(enum bcd_dog_size);

char *bcd_dog_size_string(enum bcd_dog_size);

float bcd_dog_multiplier(const struct bcd_dog *dog);

int bcd_animal_total(const struct bcd_animal_recommendations *animal,
		     float *total,
		     enum bcd_weight_unit *total_unit);

struct bcd_recommendation *
calculate_recommendation(const struct bcd_dog *dog,
			 const struct bcd_algae_powder *algae_powder);

int bcd_recommendation_for_span(unsigned int span,
				enum bcd_span_unit span_unit,
				struct bcd_recommendation *recommendation);

int bcd_recommendation_human_readable_units(
    struct bcd_recommendation *recommendation);


struct bcd_portions *bcd_food_plan(unsigned int span,
				   enum bcd_span_unit span_unit,
				   unsigned int portions_per_day,
				   const struct bcd_recommendation *base);

float bcd_span_unit_to(float value,
		       enum bcd_span_unit from,
		       enum bcd_span_unit to);

unsigned int bcd_birthdate_to_days(const int year,
				   const unsigned int month,
				   const unsigned int day);

void bcd_destroy_recommendation(struct bcd_recommendation **recommendation);
void bcd_destroy_recommendation_s(struct bcd_recommendation *recommendation);

void bcd_destroy_portions(struct bcd_portions **portions);
void bcd_destroy_portions_s(struct bcd_portions *portions);
#endif
