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
	private Boolean displayDefault = false;

	@Column(name = "map_orga")
	private String orga;

	@Column(name = "map_source")
	private String source;

	@Column(name = "map_ext_id_mapping")
	private Long extMappingID;

	@Column(name = "map_nb_inchi_match")
	private Long numberInChIMatch;

	@Column(name = "map_nb_inchi_total")
	private Long numberInChITotal;

	public MapEntity() {
		this(null);
	}

	/**
	 * @param manager
	 */
	public MapEntity(MapManager manager) {
		super();
		this.mapManagerSource = manager;
	}

	/**
	 * @return the mapManagerSource
	 */
	public MapManager getMapManagerSource() {
		return mapManagerSource;
	}

	/**
	 * @param mapManagerSource
	 *            the mapManagerSource to set
	 */
	public void setMapManagerSource(MapManager mapManagerSource) {
		this.mapManagerSource = mapManagerSource;
	}

	/**
	 * @return the displayDefault
	 */
	public Boolean getDisplayDefault() {
		return displayDefault;
	}

	/**
	 * @param displayDefault
	 *            the displayDefault to set
	 */
	public void setDisplayDefault(Boolean displayDefault) {
		this.displayDefault = displayDefault;
	}

	/**
	 * @return the orga
	 */
	public String getOrga() {
		return orga;
	}

	/**
	 * @param orga
	 *            the orga to set
	 */
	public void setOrga(String orga) {
		this.orga = orga;
	}

	/**
	 * @return the source
	 */
	public String getSource() {
		return source;
	}

	/**
	 * @param source
	 *            the source to set
	 */
	public void setSource(String source) {
		this.source = source;
	}

	/**
	 * @return the extMappingID
	 */
	public Long getExtMappingID() {
		return extMappingID;
	}

	/**
	 * @param extMappingID
	 *            the extMappingID to set
	 */
	public void setExtMappingID(Long extMappingID) {
		this.extMappingID = extMappingID;
	}

	/**
	 * @return the numberInChIMatch
	 */
	public Long getNumberInChIMatch() {
		return numberInChIMatch;
	}

	/**
	 * @param numberInChIMatch
	 *            the numberInChIMatch to set
	 */
	public void setNumberInChIMatch(Long numberInChIMatch) {
		this.numberInChIMatch = numberInChIMatch;
	}

	/**
	 * @return the numberInChITotal
	 */
	public Long getNumberInChITotal() {
		return numberInChITotal;
	}

	/**
	 * @param numberInChITotal
	 *            the numberInChITotal to set
	 */
	public void setNumberInChITotal(Long numberInChITotal) {
		this.numberInChITotal = numberInChITotal;
	}

	// @Column(name = "map_token", nullable = false)
	// private String token;

}
