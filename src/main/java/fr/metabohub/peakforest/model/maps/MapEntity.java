package fr.metabohub.peakforest.model.maps;

import javax.persistence.AttributeOverride;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.PrimaryKeyJoinColumn;
import javax.persistence.Table;

@Entity
@Table(name = "map_entity")
@AttributeOverride(name = "id", column = @Column(name = "id_map_entity"))
@PrimaryKeyJoinColumn(name = "id_map_entity")
public class MapEntity extends AbstractMapObject {

	// ////////////////////////////////////////////////////////////////////////
	// database fields

	@ManyToOne(targetEntity = MapManager.class)
	@JoinColumn(name = "map_manager_id")
	private MapManager mapManagerSource;

	@Column(name = "map_display_default")
	private Boolean displayDefault = Boolean.FALSE;

	@Column(name = "map_organism")
	private String organism;

	@Column(name = "map_biosource")
	private String biosource;

	@Column(name = "map_biosource_id")
	private String biosourceId;

	@Column(name = "map_nb_cpd_in_biosource")
	private Long nbMetabolitesInBiosource;

	@Column(name = "map_nb_cpd_with_inchikey_in_biosource")
	private Long nbMetabolitesWithInchikeyInBiosource;

	@Column(name = "map_nb_cpd_from_pforest_mapped_in_biosource")
	private Long nbMetabolitesMappedFromPForestInBiosource;

	@Column(name = "map_coverage_percent")
	private Double coverage;

	// ////////////////////////////////////////////////////////////////////////
	// constructors

	public MapEntity() {
		this(null);
	}

	public MapEntity(final MapManager manager) {
		super();
		this.mapManagerSource = manager;
	}

	// ////////////////////////////////////////////////////////////////////////
	// getters / setters

	public MapManager getMapManagerSource() {
		return mapManagerSource;
	}

	public void setMapManagerSource(final MapManager mapManagerSource) {
		this.mapManagerSource = mapManagerSource;
	}

	public Boolean getDisplayDefault() {
		return displayDefault;
	}

	public void setDisplayDefault(final Boolean displayDefault) {
		this.displayDefault = displayDefault;
	}

	public String getOrganism() {
		return organism;
	}

	public void setOrganism(final String organism) {
		this.organism = organism;
	}

	public String getBiosource() {
		return biosource;
	}

	public void setBiosource(final String biosource) {
		this.biosource = biosource;
	}

	public String getBiosourceId() {
		return biosourceId;
	}

	public void setBiosourceId(final String biosourceId) {
		this.biosourceId = biosourceId;
	}

	public Long getNbMetabolitesInBiosource() {
		return nbMetabolitesInBiosource;
	}

	public void setNbMetabolitesInBiosource(final Long nbMetabolitesInBiosource) {
		this.nbMetabolitesInBiosource = nbMetabolitesInBiosource;
	}

	public Long getNbMetabolitesWithInchikeyInBiosource() {
		return nbMetabolitesWithInchikeyInBiosource;
	}

	public void setNbMetabolitesWithInchikeyInBiosource(final Long nbMetabolitesWithInchikeyInBiosource) {
		this.nbMetabolitesWithInchikeyInBiosource = nbMetabolitesWithInchikeyInBiosource;
	}

	public Long getNbMetabolitesMappedFromPForestInBiosource() {
		return nbMetabolitesMappedFromPForestInBiosource;
	}

	public void setNbMetabolitesMappedFromPForestInBiosource(final Long nbMetabolitesMappedFromPForestInBiosource) {
		this.nbMetabolitesMappedFromPForestInBiosource = nbMetabolitesMappedFromPForestInBiosource;
	}

	public Double getCoverage() {
		return coverage;
	}

	public void setCoverage(final Double coverage) {
		this.coverage = coverage;
	}

}
