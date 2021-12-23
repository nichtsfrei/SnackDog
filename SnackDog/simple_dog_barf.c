#include "simple_dog_barf.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define YEAR_TO_MONTHS 12
#define MONTHS_TO_WEEKS 4.348214
#define WEEKS_TO_DAYS 7

#define KILO_TO_MICRO_G 1000000000
#define GRAM_TO_MICRO_G 1000000
#define MILL_TO_MICRO_G 1000

#define LOG_ALLOC_R_NULL_ERROR(x)                                              \
	fprintf(stderr, "%s: Unable to allocate %s.\n", __func__, (x));
#define ALLOC_R_NULL(x, a)                                                     \
	if (((x) = calloc(a, sizeof(*(x)))) == NULL) {                         \
		LOG_ALLOC_R_NULL_ERROR((#x));                                  \
		return NULL;                                                   \
	}

float bcd_animal_type_severity(enum bcd_animal_type animal_type)
{
	switch (animal_type) {
#define X(a, b, c)                                                             \
	case a:                                                                \
		return b;
		BCD_ANIMAL
#undef X
	};
	return 0;
}

char *bcd_animal_type_string(enum bcd_animal_type animal_type)
{
	switch (animal_type) {
#define X(a, b, c)                                                             \
	case a:                                                                \
		return c;
		BCD_ANIMAL
#undef X
	};
	return NULL;
}

char *bcd_weight_unit_string(enum bcd_weight_unit weight_unit)
{
	switch (weight_unit) {
#define X(a, b)                                                                \
	case a:                                                                \
		return b;
		BCD_WEIGHT_UNIT
#undef X
	};
	return NULL;
}

char *bcd_span_unit_string(enum bcd_span_unit span_unit)
{
	switch (span_unit) {
#define X(a, b)                                                                \
	case a:                                                                \
		return b;
		BCD_SPAN_UNIT
#undef X
	};
	return NULL;
}

float bcd_herbal_type_severity(enum bcd_herbal_type herbal_type)
{
	switch (herbal_type) {
#define X(a, b, c)                                                             \
	case a:                                                                \
		return b;
		BCD_HERBAL
#undef X
	};
	return 0;
}

char *bcd_herbal_type_string(enum bcd_herbal_type herbal_type)
{
	switch (herbal_type) {
#define X(a, b, c)                                                             \
	case a:                                                                \
		return c;
		BCD_HERBAL
#undef X
	};
	return NULL;
}

float bcd_supplement_type_severity(enum bcd_supplement_type supplement_type)
{
	switch (supplement_type) {
#define X(a, b, c)                                                             \
	case a:                                                                \
		return b;
		BCD_SUPPLEMENT
#undef X
	};
	return 0;
}

char *bcd_supplement_type_string(enum bcd_supplement_type supplement_type)
{
	switch (supplement_type) {
#define X(a, b, c)                                                             \
	case a:                                                                \
		return c;
		BCD_SUPPLEMENT
#undef X
	};
	return NULL;
}

float bcd_extra_multiplier_severity(enum bcd_extra_multiplier extra_multiplier)
{
	switch (extra_multiplier) {
#define X(a, b, c)                                                             \
	case a:                                                                \
		return b;
		BCD_EXTRA_MULTIPLIER
#undef X
	};
	return 0;
}

char *bcd_extra_multiplier_string(enum bcd_extra_multiplier extra_multiplier)
{
	switch (extra_multiplier) {
#define X(a, b, c)                                                             \
	case a:                                                                \
		return c;
		BCD_EXTRA_MULTIPLIER
#undef X
	};
	return NULL;
}

char *bcd_dog_size_string(enum bcd_dog_size dog_size)
{
	switch (dog_size) {
#define X(a, b)                                                                \
	case a:                                                                \
		return b;
		BCD_DOG_SIZE
#undef X
	};
	return NULL;
}

static float to_days(float value, enum bcd_span_unit span_unit)
{
	switch (span_unit) {
	case bcd_year:
		return value * YEAR_TO_MONTHS * MONTHS_TO_WEEKS * WEEKS_TO_DAYS;
	case bcd_month:
		return value * MONTHS_TO_WEEKS * WEEKS_TO_DAYS;
	case bcd_week:
		return value * WEEKS_TO_DAYS;
	default:
		return value;
	}
}

float bcd_span_unit_to(float value,
		       enum bcd_span_unit from,
		       enum bcd_span_unit to)
{
	float days = to_days(value, from);
	switch (to) {
	case bcd_year:
		return days / YEAR_TO_MONTHS / MONTHS_TO_WEEKS / WEEKS_TO_DAYS;
	case bcd_month:
		return days / MONTHS_TO_WEEKS / WEEKS_TO_DAYS;
	case bcd_week:
		return days / WEEKS_TO_DAYS;
	default:
		return days;
	}
}

static float
base(enum bcd_dog_size dog_size, unsigned int age, enum bcd_span_unit span_unit)
{
	float age_in_days;
	age_in_days = to_days(age, span_unit);
	switch (dog_size) {
	case bcd_dog_small:
		if (age_in_days < to_days(16, bcd_week))
			return 0.051;
		if (age_in_days < to_days(24, bcd_week))
			return 0.045;
		if (age_in_days < to_days(10, bcd_month))
			return 0.032;
		return 0.03;
	case bcd_dog_medium:
		if (age_in_days < to_days(16, bcd_week))
			return 0.054;
		if (age_in_days < to_days(24, bcd_week))
			return 0.048;
		if (age_in_days < to_days(34, bcd_week))
			return 0.038;
		if (age_in_days < to_days(12, bcd_month))
			return 0.036;
		if (age_in_days < to_days(18, bcd_month))
			return 0.03;
		return 0.025;
	default:
		if (age_in_days < to_days(16, bcd_week))
			return 0.06;
		if (age_in_days < to_days(24, bcd_week))
			return 0.054;
		if (age_in_days < to_days(38, bcd_week))
			return 0.048;
		if (age_in_days < to_days(16, bcd_month))
			return 0.042;
		if (age_in_days < to_days(24, bcd_month))
			return 0.036;
		return 0.02;
	}
}

static float activity(unsigned int activity_level_in_hours)
{
	if (activity_level_in_hours < 2)
		return 1.0;
	if (activity_level_in_hours < 3)
		return 1.25;
	if (activity_level_in_hours < 4)
		return 1.5;
	if (activity_level_in_hours < 5)
		return 1.75;
	if (activity_level_in_hours < 6)
		return 2.0;
	return 2.5;
}

static float to_micro_gram(float value, enum bcd_weight_unit weight_unit)
{
	switch (weight_unit) {
	case bcd_kilo_gram:
		return value * KILO_TO_MICRO_G;
	case bcd_gram:
		return value * GRAM_TO_MICRO_G;
	case bcd_milli_gram:
		return value * MILL_TO_MICRO_G;
	case bcd_micro_gram:
		return value;
	case bcd_kilo_liter:
		return value * KILO_TO_MICRO_G;
	case bcd_liter:
		return value * GRAM_TO_MICRO_G;
	case bcd_milli_liter:
		return value * MILL_TO_MICRO_G;
	default:
		return value;
	}
}

static float to_weight_unit(float value,
			    enum bcd_weight_unit value_unit,
			    enum bcd_weight_unit to_unit)
{
	float mg = to_micro_gram(value, value_unit);
	switch (to_unit) {
	case bcd_kilo_gram:
		return mg / KILO_TO_MICRO_G;
	case bcd_gram:
		return mg / GRAM_TO_MICRO_G;
	case bcd_milli_gram:
		return mg / MILL_TO_MICRO_G;
	case bcd_micro_gram:
		return mg;
	case bcd_kilo_liter:
		return value * KILO_TO_MICRO_G;
	case bcd_liter:
		return value * GRAM_TO_MICRO_G;
	case bcd_milli_liter:
		return value * MILL_TO_MICRO_G;
	default:
		return value;
	}
}

static float algae_powder_per_day(const struct bcd_algae_powder *algae_powder,
				  const struct bcd_dog *dog)
{
	float jod_percent, jod_algae_powder_percent;
	float age_in_days;
	age_in_days = to_days(dog->age, dog->age_unit);
	if (age_in_days < to_days(17, bcd_week))
		jod_percent = 29.0;
	else if (age_in_days < to_days(7, bcd_month))
		jod_percent = 29.0 * 0.9;
	else if (age_in_days < to_days(10, bcd_month))
		jod_percent = 29.0 * 0.8;
	else if (age_in_days < to_days(12, bcd_month))
		jod_percent = 29.0 * 0.7;
	else if (age_in_days < to_days(14, bcd_month))
		jod_percent = 29.0 * 0.6;
	else if (age_in_days < to_days(16, bcd_month))
		jod_percent = 29.0 * 0.5;
	else
		jod_percent = 12.7;
	jod_percent /= to_micro_gram(1.0, bcd_kilo_gram);

	jod_algae_powder_percent =
	    to_micro_gram(algae_powder->jod, algae_powder->jod_weight_unit) /
	    to_micro_gram(algae_powder->per, algae_powder->per_unit);
	return to_micro_gram(dog->weight, dog->weight_unit) * jod_percent /
	       jod_algae_powder_percent;
}

static struct bcd_animal_recommendations *
initialize_animal_recommendations(float food)
{
	struct bcd_animal_recommendations *recommendations;
	struct bcd_animal_recommendation *recommendation;
	ALLOC_R_NULL(recommendations, 1);
	ALLOC_R_NULL(recommendation, 4);
	recommendations->cap = 4;
	recommendations->len = 4;
	recommendation[0].amount = food * ANIMAL_PERCENTAGE *
				   bcd_animal_type_severity(bcd_animal_scallop);
	recommendation[0].weight_unit = bcd_micro_gram;
	recommendation[0].type = bcd_animal_scallop;
	recommendation[1].amount = food * ANIMAL_PERCENTAGE *
				   bcd_animal_type_severity(bcd_animal_rumen);
	recommendation[1].weight_unit = bcd_micro_gram;
	recommendation[1].type = bcd_animal_rumen;
	recommendation[2].amount = food * ANIMAL_PERCENTAGE *
				   bcd_animal_type_severity(bcd_animal_insides);
	recommendation[2].weight_unit = bcd_micro_gram;
	recommendation[2].type = bcd_animal_insides;
	recommendation[3].amount = food * ANIMAL_PERCENTAGE *
				   bcd_animal_type_severity(bcd_animal_bones);
	recommendation[3].weight_unit = bcd_micro_gram;
	recommendation[3].type = bcd_animal_bones;
	recommendations->recommendations = recommendation;
	return recommendations;
}

static struct bcd_herbal_recommendations *
initialize_herbal_recommendations(float food)
{
	struct bcd_herbal_recommendations *recommendations;
	struct bcd_herbal_recommendation *recommendation;
	ALLOC_R_NULL(recommendations, 1);
	ALLOC_R_NULL(recommendation, 2);
	recommendations->cap = 2;
	recommendations->len = 2;
	recommendation[0].amount =
	    food * HERBAL_PERCENTAGE *
	    bcd_herbal_type_severity(bcd_herbal_vegetables);
	recommendation[0].weight_unit = bcd_micro_gram;
	recommendation[0].type = bcd_herbal_vegetables;
	recommendation[1].amount = food * HERBAL_PERCENTAGE *
				   bcd_herbal_type_severity(bcd_herbal_fruits);
	recommendation[1].weight_unit = bcd_micro_gram;
	recommendation[1].type = bcd_herbal_fruits;
	recommendations->recommendations = recommendation;
	return recommendations;
}
static struct bcd_supplement_recommendations *
initialize_supplement_recommendations(float fpd, float appd)
{
	struct bcd_supplement_recommendations *recommendations;
	struct bcd_supplement_recommendation *recommendation;
	ALLOC_R_NULL(recommendations, 1);
	ALLOC_R_NULL(recommendation, 4);
	recommendations->cap = 4;
	recommendations->len = 4;
	recommendation[0].amount = appd;
	recommendation[0].weight_unit = bcd_micro_gram;
	recommendation[0].type = bcd_supplement_algae_powder;

	recommendation[1].amount =
	    fpd * bcd_supplement_type_severity(bcd_supplement_oil);
	recommendation[1].weight_unit = bcd_micro_liter;
	recommendation[1].type = bcd_supplement_oil;

	recommendation[2].amount =
	    fpd * bcd_supplement_type_severity(bcd_supplement_cod_liver_oil);
	recommendation[2].weight_unit = bcd_micro_liter;
	recommendation[2].type = bcd_supplement_cod_liver_oil;

	recommendation[3].type = bcd_supplement_fat;
	// we assume that half of the fat is comming from meat
	// TODO make that configurable.
	recommendation[3].amount =
	    fpd * (bcd_supplement_type_severity(bcd_supplement_fat) / 2) *
	    ANIMAL_PERCENTAGE;
	recommendation[3].weight_unit = bcd_micro_gram;
	recommendations->recommendations = recommendation;
	return recommendations;
}

float bcd_dog_multiplier(const struct bcd_dog *dog)
{
	float result = base(dog->size, dog->age, dog->age_unit) *
		       activity(dog->activity_level_in_hours) *
		       (dog->is_nautered || dog->is_old ? 0.9 : 1.0);
	return result > 0.1 ? 0.1 : result;
}

struct bcd_recommendation *
calculate_recommendation(const struct bcd_dog *dog,
			 const struct bcd_algae_powder *algae_powder)
{
	struct bcd_recommendation *recommendation;
	struct bcd_animal_recommendations *meat;
	struct bcd_herbal_recommendations *herbal;
	struct bcd_supplement_recommendations *supplements;

	float factor, fpd;
	ALLOC_R_NULL(recommendation, 1);
	factor = bcd_dog_multiplier(dog);

	fpd = to_micro_gram(dog->weight, dog->weight_unit) * factor;
	meat = initialize_animal_recommendations(fpd);
	herbal = initialize_herbal_recommendations(fpd);
	supplements = initialize_supplement_recommendations(
	    fpd, algae_powder_per_day(algae_powder, dog));

	recommendation->animal = meat;
	recommendation->herbal = herbal;
	recommendation->supplements = supplements;
	recommendation->span = 1;
	recommendation->span_unit = bcd_day;

	return recommendation;
}

int bcd_recommendation_for_span(unsigned int span,
				enum bcd_span_unit span_unit,
				struct bcd_recommendation *recommendation)
{
	unsigned int i;
	float new_span_percentage;
	if (recommendation == NULL) {
		return -1;
	}
	if (recommendation->animal == NULL) {
		return -2;
	}
	if (recommendation->herbal == NULL) {
		return -3;
	}
	if (recommendation->supplements == NULL) {
		return -4;
	}
	new_span_percentage =
	    to_days(span, span_unit) /
	    to_days(recommendation->span, recommendation->span_unit);

	for (i = 0; i < recommendation->herbal->len; i++)
		recommendation->herbal->recommendations[i].amount *=
		    new_span_percentage;
	for (i = 0; i < recommendation->animal->len; i++)
		recommendation->animal->recommendations[i].amount *=
		    new_span_percentage;
	for (i = 0; i < recommendation->supplements->len; i++)
		recommendation->supplements->recommendations[i].amount *=
		    new_span_percentage;
	recommendation->span = span;
	recommendation->span_unit = span_unit;

	return 0;
}

static int is_liter(enum bcd_weight_unit unit)
{
	switch (unit) {
	case bcd_kilo_liter:
	case bcd_liter:
	case bcd_milli_liter:
	case bcd_micro_liter:
		return 1;
	default:
		return 0;
	}
}

static int to_highest_weight_unit(float *value, enum bcd_weight_unit *unit)
{
	float mg;
	mg = to_micro_gram(*value, *unit);
	if (mg >= KILO_TO_MICRO_G) {
		*value = to_weight_unit(mg, bcd_micro_gram, bcd_kilo_gram);
		*unit = is_liter(*unit) ? bcd_kilo_liter : bcd_kilo_gram;
	} else if (mg >= GRAM_TO_MICRO_G) {
		*value = to_weight_unit(mg, bcd_micro_gram, bcd_gram);
		*unit = is_liter(*unit) ? bcd_liter : bcd_gram;
	} else if (mg >= MILL_TO_MICRO_G) {
		*value = to_weight_unit(mg, bcd_micro_gram, bcd_milli_gram);
		*unit = is_liter(*unit) ? bcd_milli_liter : bcd_milli_gram;
	} else {
		*value = to_weight_unit(mg, bcd_micro_gram, bcd_milli_gram);
		*unit = is_liter(*unit) ? bcd_milli_liter : bcd_milli_gram;
	}
	return 0;
}

int bcd_recommendation_human_re4adable_units(
    struct bcd_recommendation *recommendation)
{
	unsigned int i;
	if (recommendation == NULL) {
		return -1;
	}
	if (recommendation->animal == NULL) {
		return -2;
	}
	if (recommendation->herbal == NULL) {
		return -3;
	}
	if (recommendation->supplements == NULL) {
		return -4;
	}
	for (i = 0; i < recommendation->animal->len; i++) {
		if (to_highest_weight_unit(
			&recommendation->animal->recommendations[i].amount,
			&recommendation->animal->recommendations[i]
			     .weight_unit) < 0)
			return -5;
	}
	for (i = 0; i < recommendation->herbal->len; i++) {
		if (to_highest_weight_unit(
			&recommendation->herbal->recommendations[i].amount,
			&recommendation->herbal->recommendations[i]
			     .weight_unit) < 0)
			return -5;
	}
	for (i = 0; i < recommendation->supplements->len; i++) {
		if (to_highest_weight_unit(
			&recommendation->supplements->recommendations[i].amount,
			&recommendation->supplements->recommendations[i]
			     .weight_unit) < 0)
			return -5;
	}
	return 0;
}

int bcd_animal_total(const struct bcd_animal_recommendations *animal,
		     float *total,
		     enum bcd_weight_unit *total_unit)
{
	unsigned int i;
	if (animal == NULL || animal->len == 0)
		return -1;
	*total = 0;
	*total_unit = is_liter(*total_unit) ? bcd_micro_liter : bcd_micro_gram;
	for (i = 0; i < animal->len; i++) {
		*total += to_micro_gram(animal->recommendations[i].amount,
					animal->recommendations[i].weight_unit);
	}
	if (to_highest_weight_unit(total, total_unit) < 0) {
		return -2;
	}
	return 0;
}

unsigned int bcd_birthdate_to_days(const int year,
				   const unsigned int month,
				   const unsigned int day)
{
	time_t t = time(NULL);
	struct tm *tm = localtime(&t);
	int y_diff, m_diff, d_diff;
	y_diff = tm->tm_year + 1900 - year;
	m_diff = tm->tm_mon + 1 - month;
	d_diff = tm->tm_mday - day;
	return to_days(y_diff, bcd_year) + to_days(m_diff, bcd_month) + d_diff;
}

struct bcd_animal_recommendations *
base_plan(unsigned int span,
	  enum bcd_span_unit span_unit,
	  const struct bcd_recommendation *base);

static struct bcd_recommendation *
copy_recommendation(const struct bcd_recommendation *recommendation)
{
	unsigned int i;
	struct bcd_recommendation *copy;
	struct bcd_animal_recommendations *animal = NULL;
	struct bcd_herbal_recommendations *herbal = NULL;
	struct bcd_supplement_recommendations *supplements = NULL;

	if (recommendation == NULL)
		return NULL;
	if ((copy = calloc(1, sizeof(*copy))) == NULL)
		return NULL;
	copy->span = recommendation->span;
	copy->span_unit = recommendation->span_unit;
	if (recommendation->animal != NULL) {
		animal = calloc(1, sizeof(*animal));
		animal->len = recommendation->animal->len;
		animal->cap = recommendation->animal->cap;
		animal->recommendations =
		    calloc(animal->cap, sizeof(*animal->recommendations));
		for (i = 0; i < animal->len; i++) {
			animal->recommendations[i].amount =
			    recommendation->animal->recommendations[i].amount;
			animal->recommendations[i].weight_unit =
			    recommendation->animal->recommendations[i]
				.weight_unit;
			animal->recommendations[i].type =
			    recommendation->animal->recommendations[i].type;
		}
	}
	if (recommendation->herbal != NULL) {
		herbal = calloc(1, sizeof(*herbal));
		herbal->len = recommendation->herbal->len;
		herbal->cap = recommendation->herbal->cap;
		herbal->recommendations =
		    calloc(herbal->cap, sizeof(*herbal->recommendations));
		for (i = 0; i < herbal->len; i++) {
			herbal->recommendations[i].amount =
			    recommendation->herbal->recommendations[i].amount;
			herbal->recommendations[i].weight_unit =
			    recommendation->herbal->recommendations[i]
				.weight_unit;
			herbal->recommendations[i].type =
			    recommendation->herbal->recommendations[i].type;
		}
	}
	if (recommendation->supplements != NULL) {
		supplements = calloc(1, sizeof(*supplements));
		supplements->len = recommendation->supplements->len;
		supplements->cap = recommendation->supplements->cap;
		supplements->recommendations = calloc(
		    supplements->cap, sizeof(*supplements->recommendations));
		for (i = 0; i < supplements->len; i++) {
			supplements->recommendations[i].amount =
			    recommendation->supplements->recommendations[i]
				.amount;
			supplements->recommendations[i].weight_unit =
			    recommendation->supplements->recommendations[i]
				.weight_unit;
			supplements->recommendations[i].type =
			    recommendation->supplements->recommendations[i]
				.type;
		}
	}
	copy->animal = animal;
	copy->herbal = herbal;
	copy->supplements = supplements;
	return copy;
}

void bcd_destroy_recommendation(struct bcd_recommendation **recommendation)
{
	if (recommendation == NULL || *recommendation == NULL) {
		return;
	}
    bcd_destroy_recommendation_s(*recommendation);
	
	*recommendation = NULL;
}

void bcd_destroy_recommendation_s(struct bcd_recommendation *recommendation)
{
    if (recommendation == NULL)
        return;
    if (recommendation->animal != NULL) {
        free(recommendation->animal->recommendations);
        free(recommendation->animal);
    }
    if (recommendation->herbal != NULL) {
        free(recommendation->herbal->recommendations);
        free(recommendation->herbal);
    }
    if (recommendation->supplements != NULL) {
        free(recommendation->supplements->recommendations);
        free(recommendation->supplements);
    }
    free(recommendation);
}

struct bcd_portions *bcd_food_plan(unsigned int span,
				   enum bcd_span_unit span_unit,
				   unsigned int portions_per_day,
				   const struct bcd_recommendation *base)
{
	unsigned int i, j, k;
	struct bcd_recommendation *per_day = NULL;
	struct bcd_portions *portions = NULL;
	struct bcd_recommendations *r = NULL;
	// reuse animal and herbal
	struct bcd_animal_recommendations *shared_animal;
	struct bcd_herbal_recommendations *shared_herbal;
	// used for supplement settings
	struct bcd_supplement_recommendations *sr;
	struct bcd_supplement_recommendation *dsr;

	if (base == NULL || portions_per_day < 1 || span < 1)
		return NULL;

	if ((per_day = copy_recommendation(base)) == NULL)
		goto failure;
	if (bcd_recommendation_for_span(1, bcd_day, per_day) < 0)
		goto failure;

	if ((shared_animal = calloc(1, sizeof(*shared_animal))) == NULL)
		goto failure;

	if ((shared_herbal = calloc(1, sizeof(*shared_herbal))) == NULL)
		goto failure;

	if ((r = calloc(1, sizeof(*r))) == NULL)
		goto failure;

	if ((portions = calloc(1, sizeof(*portions))) == NULL)
		goto failure;

	if ((shared_animal->recommendations =
		 calloc(per_day->animal->cap,
			sizeof(*shared_animal->recommendations))) == NULL)
		goto failure;

	if ((shared_herbal->recommendations =
		 calloc(per_day->herbal->cap,
			sizeof(*shared_herbal->recommendations))) == NULL)
		goto failure;

	shared_animal->len = per_day->animal->len;
	shared_animal->cap = per_day->animal->cap;
	for (i = 0; i < per_day->animal->len; i++) {
		shared_animal->recommendations[i].amount =
		    per_day->animal->recommendations[i].amount /
		    portions_per_day;
		shared_animal->recommendations[i].weight_unit =
		    per_day->animal->recommendations[i].weight_unit;
		shared_animal->recommendations[i].type =
		    per_day->animal->recommendations[i].type;
	}

	shared_herbal->len = per_day->herbal->len;
	shared_herbal->cap = per_day->herbal->cap;
	for (i = 0; i < per_day->herbal->len; i++) {
		shared_herbal->recommendations[i].amount =
		    per_day->herbal->recommendations[i].amount /
		    portions_per_day;
		shared_herbal->recommendations[i].weight_unit =
		    per_day->herbal->recommendations[i].weight_unit;
		shared_herbal->recommendations[i].type =
		    per_day->herbal->recommendations[i].type;
	}

	r->cap = portions_per_day * to_days(span, span_unit);
	r->len = r->cap;
	r->recommendations = calloc(r->len, sizeof(*r->recommendations));
	for (i = 0, k = 0; i < r->len; i++, k++) {
		r->recommendations[i].animal = shared_animal;
		r->recommendations[i].herbal = shared_herbal;
		if ((sr = calloc(1,
				 sizeof(*r->recommendations[i].supplements))) ==
		    NULL)
			goto failure;
		if ((sr->recommendations =
			 calloc(per_day->supplements->len,
				sizeof(*sr->recommendations))) == NULL)
			goto failure;
		r->recommendations[i].supplements = sr;
		// on sundays we don't use algae_powder or cod_liver_oil to make
		// it easier to remember the pattern.
		sr->len =
		    per_day->supplements->len -
		    ((k == 0 && (i / portions_per_day + 1) % 7 == 0) ? 3 : 2);
		dsr = per_day->supplements->recommendations;
		for (j = 0; j < per_day->supplements->len; j++) {
			switch (dsr[j].type) {
			case bcd_supplement_cod_liver_oil:
				if ((i / portions_per_day) % 2 == 0) {
					break;
				}
				// fall-through	
			case bcd_supplement_algae_powder:
				// ignore sunday
				if (sr->len == per_day->supplements->len - 3 ||
				    k != 0)
					break;
				if (dsr[j].type ==
					bcd_supplement_algae_powder &&
				    (i / portions_per_day) % 2 != 0) {
					break;
				}
				sr->recommendations[sr->cap].amount =
				    dsr[j].amount * 2;
				sr->recommendations[sr->cap].type = dsr[j].type;
				sr->recommendations[sr->cap].weight_unit =
				    dsr[j].weight_unit;
				sr->cap++;
				break;
			case bcd_supplement_oil:
				if (k != portions_per_day - 1) {
					break;
				}
				sr->recommendations[sr->cap].amount =
				    dsr[j].amount;
				sr->recommendations[sr->cap].type = dsr[j].type;
				sr->recommendations[sr->cap].weight_unit =
				    dsr[j].weight_unit;
				sr->cap++;
				break;
			default:
				sr->recommendations[sr->cap].amount =
				    dsr[j].amount / 2;
				sr->recommendations[sr->cap].type = dsr[j].type;
				sr->recommendations[sr->cap].weight_unit =
				    dsr[j].weight_unit;
				sr->cap++;
			}
		}
		if (k == portions_per_day - 1)
			k = -1;
	}

	portions->span = span;
	portions->span_unit = span_unit;
	portions->portions = portions_per_day;
	portions->portions_per = bcd_day;
	portions->recommendations = r;

	bcd_destroy_recommendation(&per_day);
	return portions;
failure:
	bcd_destroy_recommendation(&per_day);
	if (r != NULL && r->recommendations != NULL)
		free(r->recommendations);
	if (r != NULL)
		free(r);
	return NULL;
}

void bcd_destroy_portions(struct bcd_portions **portions)
{
	if (portions == NULL || *portions == NULL) {
		return;
	}
	// clear shared herbal and animal recommendations
    bcd_destroy_portions_s(*portions);
	*portions = NULL;
}

void bcd_destroy_portions_s(struct bcd_portions *portions) {
    unsigned int i;
    if (portions == NULL)
        return
    free(portions
         ->recommendations->recommendations[0]
         .animal->recommendations);
    free(portions->recommendations->recommendations[0].animal);
    free(portions
         ->recommendations->recommendations[0]
         .herbal->recommendations);
    free(portions->recommendations->recommendations[0].herbal);
    // each supplement
    for (i = 0; i < portions->recommendations->len; i++) {
        free(portions
             ->recommendations->recommendations[i]
             .supplements->recommendations);
        free(portions
             ->recommendations->recommendations[i]
             .supplements);
    }
    free(portions->recommendations->recommendations);
    free(portions->recommendations);
    free(portions);
}
